#------------------------------------------------------------------------------
# Prod Environment API Gateway Module Outputs
#------------------------------------------------------------------------------

output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_execution_arn" {
  value = aws_api_gateway_rest_api.main.execution_arn
}

output "api_invoke_url" {
  value = aws_api_gateway_stage.main.invoke_url
}

output "health_endpoint" {
  value = "${aws_api_gateway_stage.main.invoke_url}/health"
}

output "release_endpoint" {
  value = "${aws_api_gateway_stage.main.invoke_url}/release"
}

output "stage_name" {
  value = aws_api_gateway_stage.main.stage_name
}
