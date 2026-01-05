#------------------------------------------------------------------------------
# Dev Environment Lambda Module Variables
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the artifacts bucket"
  type        = string
}

variable "lambda_artifact_key" {
  description = "S3 key for the Lambda artifact"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB"
  type        = number
}

variable "release_version" {
  description = "Release version for metadata"
  type        = string
}

variable "git_commit" {
  description = "Git commit SHA"
  type        = string
}

variable "build_id" {
  description = "CI/CD build ID"
  type        = string
}
