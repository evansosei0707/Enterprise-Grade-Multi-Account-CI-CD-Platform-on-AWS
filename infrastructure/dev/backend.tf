#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Dev Environment Backend
#------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "enterprise-cicd-terraform-state-257016720202"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "enterprise-cicd-terraform-locks"
    
    # NOTE: Backend must be initialized with access to Tooling account
    # This can be done via:
    # 1. AWS_PROFILE pointing to a role with cross-account access
    # 2. Or running from GitHub Actions with assumed role
  }
}
