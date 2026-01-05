#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Tooling Account Main
#------------------------------------------------------------------------------
# NOTE: This account is TEMPORARILY using the Governance account (257016720202)
#       Replace the tooling_account_id when the actual Tooling account is approved
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Module - Encryption Keys
#------------------------------------------------------------------------------

module "kms" {
  source = "./kms"

  project_name       = var.project_name
  environment        = var.environment
  tooling_account_id = var.tooling_account_id # ⚠️ TEMPORARY: Governance account
  dev_account_id     = var.dev_account_id
  staging_account_id = var.staging_account_id
  prod_account_id    = var.prod_account_id
}

#------------------------------------------------------------------------------
# S3 Module - Terraform State and Artifacts Buckets
#------------------------------------------------------------------------------

module "s3" {
  source = "./s3"

  project_name                = var.project_name
  environment                 = var.environment
  terraform_state_bucket_name = var.terraform_state_bucket_name
  artifacts_bucket_name       = var.artifacts_bucket_name
  kms_key_arn                 = module.kms.kms_key_arn
  tooling_account_id          = var.tooling_account_id # ⚠️ TEMPORARY: Governance account
  dev_account_id              = var.dev_account_id
  staging_account_id          = var.staging_account_id
  prod_account_id             = var.prod_account_id
}

#------------------------------------------------------------------------------
# DynamoDB Module - Terraform State Locking
#------------------------------------------------------------------------------

module "dynamodb" {
  source = "./dynamodb"

  project_name        = var.project_name
  environment         = var.environment
  dynamodb_table_name = var.dynamodb_table_name
}

#------------------------------------------------------------------------------
# IAM Module - GitHub OIDC and CI/CD Roles
#------------------------------------------------------------------------------

module "iam" {
  source = "./iam"

  project_name               = var.project_name
  environment                = var.environment
  github_org                 = var.github_org
  github_repo                = var.github_repo
  github_branch              = var.github_branch
  tooling_account_id         = var.tooling_account_id # ⚠️ TEMPORARY: Governance account
  dev_account_id             = var.dev_account_id
  staging_account_id         = var.staging_account_id
  prod_account_id            = var.prod_account_id
  terraform_state_bucket_arn = module.s3.terraform_state_bucket_arn
  artifacts_bucket_arn       = module.s3.artifacts_bucket_arn
  dynamodb_table_arn         = module.dynamodb.dynamodb_table_arn
  kms_key_arn                = module.kms.kms_key_arn
}
