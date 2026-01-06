#------------------------------------------------------------------------------
# Prod Environment Lambda - Release Metadata API
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-release-metadata"
  retention_in_days = 90 # Longer retention for production

  tags = {
    Name          = "${var.project_name}-${var.environment}-lambda-logs"
    Environment   = var.environment
    SecurityLevel = "HIGH"
  }

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_lambda_function" "release_metadata" {
  function_name = "${var.project_name}-${var.environment}-release-metadata"
  role          = var.lambda_execution_role_arn
  handler       = "handler.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.artifacts_bucket_name
  s3_key    = var.lambda_artifact_key

  environment {
    variables = {
      ENVIRONMENT     = var.environment
      RELEASE_VERSION = var.release_version
      GIT_COMMIT      = var.git_commit
      BUILD_ID        = var.build_id
      DEPLOYED_AT     = timestamp()
      SERVICE_NAME    = "platform-demo-api"
    }
  }

  # Reserved concurrent executions for production stability
  # Reduced to avoid exceeding account unreserved concurrency minimum
  reserved_concurrent_executions = 10

  depends_on = [aws_cloudwatch_log_group.lambda]

  tags = {
    Name          = "${var.project_name}-${var.environment}-release-metadata"
    Environment   = var.environment
    Version       = var.release_version
    GitCommit     = var.git_commit
    SecurityLevel = "HIGH"
  }

  lifecycle {
    ignore_changes = [environment[0].variables["DEPLOYED_AT"]]
  }
}
