#------------------------------------------------------------------------------
# Enterprise Multi-Account CI/CD Platform - Prod Environment Outputs
#------------------------------------------------------------------------------

output "deploy_role_arn" {
  description = "ARN of the deploy role (for GitHub Actions)"
  value       = module.iam.deploy_role_arn
}

output "lambda_execution_role_arn" {
  value = module.iam.lambda_execution_role_arn
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}

output "api_invoke_url" {
  value = module.apigateway.api_invoke_url
}

output "health_endpoint" {
  value = module.apigateway.health_endpoint
}

output "release_endpoint" {
  value = module.apigateway.release_endpoint
}

output "summary" {
  value = <<-EOT
    
    ============================================================
    PROD ENVIRONMENT DEPLOYED
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
