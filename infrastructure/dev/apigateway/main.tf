#------------------------------------------------------------------------------
# Dev Environment API Gateway - Release Metadata API
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# REST API
#------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-${var.api_name}"
  description = "Release Metadata API for ${var.environment} environment"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-api"
    Environment = var.environment
  }
}

#------------------------------------------------------------------------------
# /health Resource and Method
#------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

#------------------------------------------------------------------------------
# /release Resource and Method
#------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "release" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "release"
}

resource "aws_api_gateway_method" "release_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.release.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "release_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.release.id
  http_method = aws_api_gateway_method.release_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

#------------------------------------------------------------------------------
# Lambda Permission for API Gateway
#------------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # Allow invocation from any stage/method/resource in this API
  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

#------------------------------------------------------------------------------
# Deployment and Stage
#------------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  # Force new deployment when any of these change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.health.id,
      aws_api_gateway_resource.release.id,
      aws_api_gateway_method.health_get.id,
      aws_api_gateway_method.release_get.id,
      aws_api_gateway_integration.health_lambda.id,
      aws_api_gateway_integration.release_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.health_lambda,
    aws_api_gateway_integration.release_lambda
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-${var.environment}-stage"
    Environment = var.environment
  }
}
