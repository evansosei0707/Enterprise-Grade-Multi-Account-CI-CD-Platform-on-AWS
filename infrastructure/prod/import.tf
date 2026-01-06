# Terraform Import Blocks for Production
# These will automatically import existing resources into state during terraform plan

import {
  to = module.lambda.aws_cloudwatch_log_group.lambda
  id = "/aws/lambda/enterprise-cicd-prod-release-metadata"
}

import {
  to = module.lambda.aws_lambda_function.release_metadata
  id = "enterprise-cicd-prod-release-metadata"
}
