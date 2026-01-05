#------------------------------------------------------------------------------
# Staging Environment API Gateway Module Variables
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

variable "api_name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}
