#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Tooling Account Providers
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
# AWS Provider Configuration
# NOTE: This uses the Governance account temporarily until Tooling is approved
#------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
    profile = "governance"

  default_tags {
    tags = var.common_tags
  }
}
