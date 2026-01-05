#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Tooling Account Backend
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# LOCAL BACKEND (Initial Bootstrap)
# Comment this out after migrating to S3
#------------------------------------------------------------------------------
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }

#------------------------------------------------------------------------------
# S3 BACKEND (Production - Enable after bootstrap)
# Uncomment this block after S3 bucket and DynamoDB table are created
#------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "enterprise-cicd-terraform-state-257016720202"
    key            = "tooling/terraform.tfstate"
    region         = "us-east-1"
    profile        = "governance"
    encrypt        = true
    dynamodb_table = "enterprise-cicd-terraform-locks"
  }
}
