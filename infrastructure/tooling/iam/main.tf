#------------------------------------------------------------------------------
# IAM Module - GitHub OIDC Provider and CI/CD Roles
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# GitHub OIDC Identity Provider
# This allows GitHub Actions to authenticate without long-lived credentials
#------------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint (this is a known, stable value)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name    = "${var.project_name}-github-oidc"
    Purpose = "GitHub Actions OIDC Authentication"
  }
}

#------------------------------------------------------------------------------
# GitHub Actions IAM Role
# This role is assumed by GitHub Actions via OIDC
# NOTE: Trust policy restricts to main branch only
#------------------------------------------------------------------------------

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

  # Trust policy - allows GitHub Actions from specific repo (branch or environment)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Allow both branch-based (Dev) and environment-based (Staging/Prod) workflows
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-github-actions-role"
    Purpose = "Role assumed by GitHub Actions via OIDC"
  }
}

#------------------------------------------------------------------------------
# Policy: Cross-Account Role Assumption
# Allows GitHub Actions role to assume roles in Dev/Staging/Prod accounts
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "assume_environment_roles" {
  name = "${var.project_name}-assume-environment-roles"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AssumeEnvironmentRoles"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = [
          "arn:aws:iam::${var.dev_account_id}:role/${var.project_name}-deploy-role",
          "arn:aws:iam::${var.staging_account_id}:role/${var.project_name}-deploy-role",
          "arn:aws:iam::${var.prod_account_id}:role/${var.project_name}-deploy-role"
        ]
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Policy: Terraform State Access
# Allows reading/writing Terraform state and acquiring locks
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "terraform_state_access" {
  name = "${var.project_name}-terraform-state-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.terraform_state_bucket_arn,
          "${var.terraform_state_bucket_arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Policy: Artifacts Bucket Access
# Allows uploading and reading artifacts (Lambda ZIPs, etc.)
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "artifacts_access" {
  name = "${var.project_name}-artifacts-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ArtifactsAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ]
        Resource = [
          var.artifacts_bucket_arn,
          "${var.artifacts_bucket_arn}/*"
        ]
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Policy: KMS Access
# Allows encrypting/decrypting with the KMS key
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "kms_access" {
  name = "${var.project_name}-kms-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}
