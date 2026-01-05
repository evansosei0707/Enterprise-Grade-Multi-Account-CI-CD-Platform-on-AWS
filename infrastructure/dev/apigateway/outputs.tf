#------------------------------------------------------------------------------
# Dev Environment API Gateway Module Outputs
#------------------------------------------------------------------------------

output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_invoke_url" {
  description = "Base URL to invoke the API"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "health_endpoint" {
  description = "Full URL for the /health endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/health"
}

output "release_endpoint" {
  description = "Full URL for the /release endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/release"
}

output "stage_name" {
  description = "Name of the deployment stage"
  value       = aws_api_gateway_stage.main.stage_name
}
