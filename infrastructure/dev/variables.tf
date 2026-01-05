#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Dev Environment Variables
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
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

#------------------------------------------------------------------------------
# AWS Account IDs
#------------------------------------------------------------------------------

variable "tooling_account_id" {
  description = "AWS Tooling (CI/CD) account ID - TEMPORARILY USING GOVERNANCE ACCOUNT"
  type        = string
  default     = "257016720202" # ⚠️ TEMPORARY
}

variable "dev_account_id" {
  description = "AWS Dev account ID"
  type        = string
  default     = "067847734974"
}

#------------------------------------------------------------------------------
# Deployment Configuration (Cross-Account)
#------------------------------------------------------------------------------

variable "deploy_role_arn" {
  description = "ARN of the role to assume for deployment (if running from Tooling account)"
  type        = string
  default     = "" # Optional, if empty will use current credentials
}

#------------------------------------------------------------------------------
# Artifact Configuration
#------------------------------------------------------------------------------

variable "artifacts_bucket_name" {
  description = "Name of the artifacts bucket in Tooling account"
  type        = string
  default     = "enterprise-cicd-artifacts-257016720202"
}

variable "lambda_artifact_key" {
  description = "S3 key for the Lambda deployment package"
  type        = string
  default     = "lambda/release-metadata-api.zip"
}

#------------------------------------------------------------------------------
# Application Configuration
#------------------------------------------------------------------------------

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "release-metadata-api"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

#------------------------------------------------------------------------------
# Release Metadata (injected by CI/CD)
#------------------------------------------------------------------------------

variable "release_version" {
  description = "Current release version"
  type        = string
  default     = "1.0.0"
}

variable "git_commit" {
  description = "Git commit SHA"
  type        = string
  default     = "local"
}

variable "build_id" {
  description = "CI/CD build ID"
  type        = string
  default     = "local-build"
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
    Environment = "dev"
  }
}
