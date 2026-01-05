#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Dev Environment Providers
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# AWS Provider Configuration for Dev Account
#------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  # Cross-account role assumption
  # If deploy_role_arn is provided, assume it. Otherwise use default creds.
  dynamic "assume_role" {
    for_each = var.deploy_role_arn != "" ? [1] : []
    content {
      role_arn = var.deploy_role_arn
    }
  }

  default_tags {
    tags = var.common_tags
  }
}
