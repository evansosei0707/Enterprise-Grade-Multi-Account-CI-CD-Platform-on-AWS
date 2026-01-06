#------------------------------------------------------------------------------
# Import Blocks for Existing Resources
#------------------------------------------------------------------------------
# These import blocks will automatically import existing resources into
# Terraform state on the next terraform plan/apply, preventing the
# "ResourceAlreadyExistsException" errors.
#
# After the first successful apply, this file can be safely deleted.
#------------------------------------------------------------------------------

import {
  to = module.lambda.aws_cloudwatch_log_group.lambda
  id = "/aws/lambda/enterprise-cicd-dev-release-metadata"
}

import {
  to = module.lambda.aws_lambda_function.release_metadata
  id = "enterprise-cicd-dev-release-metadata"
}
