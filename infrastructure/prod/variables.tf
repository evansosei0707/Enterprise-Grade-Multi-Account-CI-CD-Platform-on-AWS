variable "project_name" {
  type    = string
  default = "enterprise-cicd"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tooling_account_id" {
  type    = string
  default = "257016720202" # ⚠️ TEMPORARY
}

variable "prod_account_id" {
  type    = string
  default = "235249476696"
}

variable "deploy_role_arn" {
  description = "ARN of the role to assume for deployment"
  type        = string
  default     = ""
}

variable "artifacts_bucket_name" {
  type    = string
  default = "enterprise-cicd-artifacts-257016720202"
}

variable "lambda_artifact_key" {
  type = string
}

variable "api_name" {
  type    = string
  default = "release-metadata-api"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.11"
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "lambda_memory_size" {
  type    = number
  default = 128
}

variable "release_version" {
  type = string
}

variable "git_commit" {
  type = string
}

variable "build_id" {
  type = string
}

variable "common_tags" {
  type = map(string)
  default = {
    Project     = "Enterprise-CICD-Platform"
    ManagedBy   = "Terraform"
    Environment = "prod"
  }
}
