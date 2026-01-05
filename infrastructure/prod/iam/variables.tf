#------------------------------------------------------------------------------
# Prod Environment IAM Module Variables
#------------------------------------------------------------------------------

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tooling_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}
