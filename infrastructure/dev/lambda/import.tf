#------------------------------------------------------------------------------
# Import Block for Existing CloudWatch Log Group
#------------------------------------------------------------------------------
# This import block will automatically import the existing log group into
# Terraform state on the next terraform plan/apply, preventing the
# "ResourceAlreadyExistsException" error.
#
# After the first successful apply, this file can be safely deleted.
#------------------------------------------------------------------------------

import {
  to = aws_cloudwatch_log_group.lambda
  id = "/aws/lambda/enterprise-cicd-dev-release-metadata"
}
