#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Tooling Account Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Outputs
#------------------------------------------------------------------------------

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.kms.kms_key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.kms.kms_key_arn
}

#------------------------------------------------------------------------------
# S3 Outputs
#------------------------------------------------------------------------------

output "terraform_state_bucket_id" {
  description = "ID of the Terraform state bucket"
  value       = module.s3.terraform_state_bucket_id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = module.s3.terraform_state_bucket_arn
}

output "artifacts_bucket_id" {
  description = "ID of the artifacts bucket"
  value       = module.s3.artifacts_bucket_id
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket"
  value       = module.s3.artifacts_bucket_arn
}

#------------------------------------------------------------------------------
# DynamoDB Outputs
#------------------------------------------------------------------------------

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_arn
}

#------------------------------------------------------------------------------
# IAM Outputs
#------------------------------------------------------------------------------

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = module.iam.github_oidc_provider_arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role (use this in GitHub workflow)"
  value       = module.iam.github_actions_role_arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = module.iam.github_actions_role_name
}

#------------------------------------------------------------------------------
# Helpful Output for Next Steps
#------------------------------------------------------------------------------

output "next_steps" {
  description = "Instructions for state migration"
  value       = <<-EOT
    
    ============================================================
    TOOLING ACCOUNT DEPLOYMENT COMPLETE
    ============================================================
    
    Next Steps:
    1. Note the github_actions_role_arn - you'll need this in GitHub workflows
    2. To migrate state to S3:
       a. Uncomment the S3 backend in backend.tf
       b. Comment out the local backend
       c. Run: terraform init -migrate-state
    
    GitHub Actions Role ARN: ${module.iam.github_actions_role_arn}
    State Bucket: ${module.s3.terraform_state_bucket_id}
    DynamoDB Table: ${module.dynamodb.dynamodb_table_name}
    
    ============================================================
  EOT
}
