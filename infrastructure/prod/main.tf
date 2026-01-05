#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Prod Environment Main
#------------------------------------------------------------------------------

module "iam" {
  source = "./iam"

  project_name       = var.project_name
  environment        = var.environment
  tooling_account_id = var.tooling_account_id
  aws_region         = var.aws_region
}

module "lambda" {
  source = "./lambda"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  artifacts_bucket_name     = var.artifacts_bucket_name
  lambda_artifact_key       = var.lambda_artifact_key
  lambda_runtime            = var.lambda_runtime
  lambda_timeout            = var.lambda_timeout
  lambda_memory_size        = var.lambda_memory_size
  release_version           = var.release_version
  git_commit                = var.git_commit
  build_id                  = var.build_id
}

module "apigateway" {
  source = "./apigateway"

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  api_name             = var.api_name
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
}
