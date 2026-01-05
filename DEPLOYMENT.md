# 🚀 Deployment Guide: Enterprise Multi-Account CI/CD Platform

This document details the **step-by-step process** to deploy the entire platform from scratch. It assumes you are starting with a fresh GitHub repository and the provided AWS account IDs.

---

## 📋 Prerequisites

1.  **Terraform** (v1.5.0+) installed.
2.  **AWS CLI** (v2+) installed and configured.
3.  **GitHub Account** with access to the repository.
4.  **AWS Credentials** for the **Tooling Account** (currently Governance) with Administrator privileges.

---

## 🛠️ Phase 1: Tooling Account Bootstrap (Manual)

We must manually create the Tooling account infrastructure first because Terraform cannot store its state in an S3 bucket that doesn't exist yet.

### Step 1.1: Configure AWS Credentials

Ensure you are authenticated as an Administrator in the **Governance Account** (257016720202), which serves as our temporary Tooling account.

```bash
aws configure
# AWS Access Key ID: [YOUR_ACCESS_KEY]
# AWS Secret Access Key: [YOUR_SECRET_KEY]
# Default region name: us-east-1
# Default output format: json
```

Verify identity:
```bash
aws sts get-caller-identity
# Should return Account: "257016720202"
```

### Step 1.2: Initialize Local Terraform

Navigate to the tooling infrastructure directory:

```bash
cd infrastructure/tooling
```

Initialize Terraform (this uses `backend.tf` configured for **local** state):

```bash
terraform init
```

### Step 1.3: Apply Tooling Infrastructure

Review the plan:
```bash
terraform plan
```

Apply the configuration. This creates:
*   S3 Bucket for Terraform State (`enterprise-cicd-terraform-state-257016720202`)
*   DynamoDB Table for State Locking (`enterprise-cicd-terraform-locks`)
*   S3 Bucket for Artifacts (`enterprise-cicd-artifacts-257016720202`)
*   KMS Keys
*   GitHub OIDC Provider & IAM Roles

```bash
terraform apply
# Type 'yes' to confirm
```

### Step 1.4: Migrate State to S3

Now that the S3 bucket exists, we move the `terraform.tfstate` file from your local machine to the secure bucket.

1.  Open `infrastructure/tooling/backend.tf`.
2.  **Comment out** the `backend "local"` block.
3.  **Uncomment** the `backend "s3"` block.

It should look like this:

```hcl
# backend.tf

# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }

terraform {
  backend "s3" {
    bucket         = "enterprise-cicd-terraform-state-257016720202"
    key            = "tooling/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "enterprise-cicd-terraform-locks"
  }
}
```

4.  Run migration command:

```bash
terraform init -migrate-state
# Type 'yes' to confirm copying state to S3
```

**✅ Tooling Account is now fully bootstrapped.** Terraform state is secure, and OIDC is ready for GitHub Actions.

---

## 🌐 Phase 2: GitHub Configuration

The Terraform code in Phase 1 created an IAM OIDC Provider that trusts your GitHub repository (`evansosei0707/Enterprise-Grade-Multi-Account-CI-CD-Platform-on-AWS`).

### Step 2.1: Verify Repository Settings

1.  Go to your GitHub Repository.
2.  Ensure the default branch is named `main` (as defined in `variables.tf`).
3.  **Security Recommendation**: In Settings > Environments, create environments for `staging` and `prod`.
    *   **Staging**: Add "Required reviewers".
    *   **Prod**: Add "Required reviewers" (e.g., yourself).
    *   *This enforces the manual approval gate defined in the workflows.*

---

## 🚀 Phase 3: Deployment (Automated)

The rest of the infrastructure (Dev, Staging, Prod) is deployed automatically via GitHub Actions.

### Step 3.1: Deploy to Dev

1.  Make a small change to the repo (e.g., update README) or simply trigger the workflow manually.
2.  Go to **Actions** > **Deploy to Dev**.
3.  Click **Run workflow** (branch: `main`).

**What happens:**
*   GitHub authenticates via OIDC.
*   Builds `release-metadata-api.zip`.
*   Uploads it to S3: `s3://enterprise-cicd-artifacts-257016720202/lambda/release-metadata-api-[SHA].zip`.
*   Runs `terraform apply` for the **Dev** environment.

**Verify Dev:**
Find the API URL in the GitHub Actions logs (Deployment Summary) or AWS Console. Used `curl` to test:
```bash
curl https://[api-id].execute-api.us-east-1.amazonaws.com/dev/health
curl https://[api-id].execute-api.us-east-1.amazonaws.com/dev/release
```

### Step 3.2: Promote to Staging

Once Dev is stable, promote the **exact same artifact** to Staging.

1.  Copy the **Commit SHA** that was successfully deployed to Dev.
2.  Go to **Actions** > **Deploy to Staging**.
3.  Click **Run workflow**.
4.  Input the **Commit SHA**.
5.  **Approvals**: If you configured GitHub Environments, the workflow will pause and ask for approval. Click "Review deployments" -> "Approve".

**What happens:**
*   Pipeline downloads the *existing* artifact for that SHA (ensuring immutability).
*   Runs `terraform apply` for **Staging** (stricter permissions).

**Verify Staging:**
```bash
curl https://[api-id].execute-api.us-east-1.amazonaws.com/staging/release
# Should show the SAME git_commit as Dev
```

### Step 3.3: Promote to Prod

Finally, deploy to Production.

1.  Go to **Actions** > **Deploy to Prod**.
2.  Click **Run workflow**.
3.  Input the **Commit SHA**.
4.  **Approvals**: Critical approval step.

**What happens:**
*   Runs `terraform apply` for **Prod** (most restrictive permissions, deny-first policies).
*   Deploys to the production API Gateway stage.

**Verify Prod:**
```bash
curl https://[api-id].execute-api.us-east-1.amazonaws.com/prod/release
```

---

## 🧹 Maintenance & Cleanup

### Modifying Infrastructure
*   **Tooling Account**: Modify TF files locally, run `terraform apply` locally (authenticated as Admin).
*   **Environments**: Modify TF files, push to git. CI/CD handles the rest.

### Destroying Resources (Teardown)
To destroy everything (e.g., to stop costs):

1.  **Destroy Prod/Staging/Dev**: A "Destroy" workflow is not provided for safety. You must run this locally or create a special workflow.
    *   `terraform destroy` in each folder, specifically providing the `deploy_role_arn` if running locally, or assume the correct role.
2.  **Destroy Tooling**:
    *   `cd infrastructure/tooling`
    *   `terraform destroy`
    *   *Note: You may need to manually empty the S3 buckets first.*

---

## 🆘 Troubleshooting

*   **Error: "Access Denied" on S3 State**: Ensure your local user or CI role has permission to the S3 bucket in the Tooling account.
*   **Error: "OIDC Token" failures**: Check `infrastructure/tooling/iam/main.tf` to ensure `github_repo` matches your repo exactly (case-sensitive).
*   **Error: "Artifact not found"**: Ensure you ran `Deploy to Dev` *first* for that specific commit SHA. Staging/Prod depend on the artifact existing.
