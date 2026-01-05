#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Dev Environment Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# IAM Outputs
#------------------------------------------------------------------------------

output "deploy_role_arn" {
  description = "ARN of the deploy role (for GitHub Actions)"
  value       = module.iam.deploy_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam.lambda_execution_role_arn
}

#------------------------------------------------------------------------------
# Lambda Outputs
#------------------------------------------------------------------------------

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.lambda_function_arn
}

#------------------------------------------------------------------------------
# API Gateway Outputs
#------------------------------------------------------------------------------

output "api_invoke_url" {
  description = "Base URL to invoke the API"
  value       = module.apigateway.api_invoke_url
}

output "health_endpoint" {
  description = "Full URL for the /health endpoint"
  value       = module.apigateway.health_endpoint
}

output "release_endpoint" {
  description = "Full URL for the /release endpoint"
  value       = module.apigateway.release_endpoint
}

#------------------------------------------------------------------------------
# Helpful Summary
#------------------------------------------------------------------------------

output "summary" {
  description = "Deployment summary"
  value       = <<-EOT
    
    ============================================================
    DEV ENVIRONMENT DEPLOYED
    ============================================================
    
    API Endpoints:
      Health:  ${module.apigateway.health_endpoint}
      Release: ${module.apigateway.release_endpoint}
    
    Test with:
      curl ${module.apigateway.health_endpoint}
      curl ${module.apigateway.release_endpoint}
    
    ============================================================
  EOT
}
