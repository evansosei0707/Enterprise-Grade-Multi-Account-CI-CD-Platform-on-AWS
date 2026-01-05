#------------------------------------------------------------------------------
# Dev Environment Lambda Module Outputs
#------------------------------------------------------------------------------

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.release_metadata.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.release_metadata.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.release_metadata.invoke_arn
}

output "lambda_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}
