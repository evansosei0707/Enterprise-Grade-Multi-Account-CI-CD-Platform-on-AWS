#------------------------------------------------------------------------------
# Prod Environment Lambda Module Outputs
#------------------------------------------------------------------------------

output "lambda_function_name" {
  value = aws_lambda_function.release_metadata.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.release_metadata.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.release_metadata.invoke_arn
}

output "lambda_log_group_name" {
  value = aws_cloudwatch_log_group.lambda.name
}
