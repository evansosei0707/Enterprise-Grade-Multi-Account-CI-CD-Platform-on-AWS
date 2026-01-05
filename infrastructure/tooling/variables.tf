#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Tooling Account Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "enterprise-cicd"
}

variable "environment" {
  description = "Environment name for the tooling account"
  type        = string
  default     = "tooling"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

#------------------------------------------------------------------------------
# AWS Account IDs
# NOTE: tooling_account_id currently uses Governance account (257016720202)
#       Replace with actual Tooling account ID when approved
#------------------------------------------------------------------------------

variable "management_account_id" {
  description = "AWS Management account ID"
  type        = string
  default     = "332871856333"
}

variable "governance_account_id" {
  description = "AWS Governance account ID"
  type        = string
  default     = "257016720202"
}

# TODO: Replace this with actual Tooling account ID when approved
# Currently using Governance account ID as temporary substitute
variable "tooling_account_id" {
  description = "AWS Tooling (CI/CD) account ID - TEMPORARILY USING GOVERNANCE ACCOUNT"
  type        = string
  default     = "257016720202" # ⚠️ TEMPORARY: Using Governance account until Tooling is approved
}

variable "dev_account_id" {
  description = "AWS Dev account ID"
  type        = string
  default     = "067847734974"
}

variable "staging_account_id" {
  description = "AWS Staging account ID"
  type        = string
  default     = "956574163435"
}

variable "prod_account_id" {
  description = "AWS Prod account ID"
  type        = string
  default     = "235249476696"
}

#------------------------------------------------------------------------------
# GitHub Configuration (for OIDC)
#------------------------------------------------------------------------------

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = "evansosei0707"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "Enterprise-Grade-Multi-Account-CI-CD-Platform-on-AWS"
}

variable "github_branch" {
  description = "GitHub branch allowed to assume roles"
  type        = string
  default     = "main"
}

#------------------------------------------------------------------------------
# Resource Naming
#------------------------------------------------------------------------------

variable "terraform_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "enterprise-cicd-terraform-state-257016720202"
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for CI/CD artifacts"
  type        = string
  default     = "enterprise-cicd-artifacts-257016720202"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "enterprise-cicd-terraform-locks"
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "Enterprise-CICD-Platform"
    ManagedBy   = "Terraform"
    Environment = "tooling"
  }
}
