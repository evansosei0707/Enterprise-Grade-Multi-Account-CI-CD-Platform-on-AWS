#------------------------------------------------------------------------------
# Prod Environment Lambda Module Variables
#------------------------------------------------------------------------------

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "lambda_execution_role_arn" {
  type = string
}

variable "artifacts_bucket_name" {
  type = string
}

variable "lambda_artifact_key" {
  type = string
}

variable "lambda_runtime" {
  type = string
}

variable "lambda_timeout" {
  type = number
}

variable "lambda_memory_size" {
  type = number
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
