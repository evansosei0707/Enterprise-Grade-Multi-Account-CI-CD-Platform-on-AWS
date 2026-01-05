#------------------------------------------------------------------------------
# S3 Module Variables
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "tooling_account_id" {
  description = "Tooling account ID"
  type        = string
}

variable "dev_account_id" {
  description = "Dev account ID for cross-account access"
  type        = string
}

variable "staging_account_id" {
  description = "Staging account ID for cross-account access"
  type        = string
}

variable "prod_account_id" {
  description = "Prod account ID for cross-account access"
  type        = string
}
