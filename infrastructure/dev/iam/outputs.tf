#------------------------------------------------------------------------------
# Dev Environment IAM Module Outputs
#------------------------------------------------------------------------------

output "deploy_role_arn" {
  description = "ARN of the deploy role"
  value       = aws_iam_role.deploy_role.arn
}

output "deploy_role_name" {
  description = "Name of the deploy role"
  value       = aws_iam_role.deploy_role.name
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}
