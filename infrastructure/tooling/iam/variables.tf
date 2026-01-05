#------------------------------------------------------------------------------
# IAM Module Variables
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume roles"
  type        = string
}

variable "tooling_account_id" {
  description = "Tooling account ID"
  type        = string
}

variable "dev_account_id" {
  description = "Dev account ID"
  type        = string
}

variable "staging_account_id" {
  description = "Staging account ID"
  type        = string
}

variable "prod_account_id" {
  description = "Prod account ID"
  type        = string
}

variable "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key"
  type        = string
}
