#------------------------------------------------------------------------------
# KMS Module - Encryption Keys for Terraform State and Artifacts
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
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

variable "tooling_account_id" {
  description = "Tooling account ID"
  type        = string
}
