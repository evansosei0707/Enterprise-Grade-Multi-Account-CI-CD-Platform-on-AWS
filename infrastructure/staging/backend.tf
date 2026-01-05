#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Staging Environment Backend
#------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "enterprise-cicd-terraform-state-257016720202"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "enterprise-cicd-terraform-locks"
  }
}
