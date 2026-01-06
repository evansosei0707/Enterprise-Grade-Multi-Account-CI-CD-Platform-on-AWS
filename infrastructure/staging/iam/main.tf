#------------------------------------------------------------------------------
# Staging Environment IAM - Cross-Account Deploy Role (STRICTER THAN DEV)
#------------------------------------------------------------------------------
# Staging has stricter permissions than Dev:
# - Narrower resource patterns
# - No delete permissions for critical resources
# - More specific conditions
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Deploy Role - Assumed from Tooling Account
#------------------------------------------------------------------------------

resource "aws_iam_role" "deploy_role" {
  name = "${var.project_name}-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # NOTE: Uses tooling_account_id which is temporarily Governance account
          AWS = "arn:aws:iam::${var.tooling_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${var.tooling_account_id}:role/${var.project_name}-github-actions-role"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-deploy-role"
    Environment = var.environment
    Purpose     = "Cross-account deployment role for CI/CD"
  }
}

#------------------------------------------------------------------------------
# Deploy Policy - STRICTER Permissions for Staging
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "deploy_policy" {
  name = "${var.project_name}-deploy-policy"
  role = aws_iam_role.deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lambda permissions - NO DELETE in staging
      {
        Sid    = "LambdaManagement"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:ListFunctions",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
          "lambda:InvokeFunction",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:GetPolicy",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:ListTags"
          # NOTE: DeleteFunction is NOT allowed in staging
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:*:function:${var.project_name}-${var.environment}-*"
        ]
      },
      # API Gateway permissions - More restricted
      {
        Sid    = "APIGatewayManagement"
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:PATCH"
          # NOTE: DELETE is NOT allowed in staging
        ]
        Resource = [
          "arn:aws:apigateway:${var.aws_region}::/*"
        ]
      },
      # CloudWatch Logs - Read/List (Global required for Terraform state checks)
      {
        Sid    = "CloudWatchLogsRead"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:ListTagsForResource"
        ]
        Resource = "*"
      },
      # CloudWatch Logs - Write (Restricted to project, no delete)
      {
        Sid    = "CloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:TagResource",
          "logs:PutRetentionPolicy"
          # NOTE: Delete actions NOT allowed
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-${var.environment}-*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-${var.environment}-*:*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/api-gateway/${var.project_name}-${var.environment}-*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/api-gateway/${var.project_name}-${var.environment}-*:*"
        ]
      },
      # IAM for Lambda - No delete
      {
        Sid    = "IAMForLambda"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
          # NOTE: Delete/Detach actions NOT allowed
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.project_name}-${var.environment}-*"
        ]
      },
      # S3 for artifacts - Read only
      {
        Sid    = "S3ArtifactsRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::enterprise-cicd-artifacts-${var.tooling_account_id}/*"
        ]
      },
      # KMS for decryption
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          "*"
        ]
        Condition = {
          StringLike = {
            "kms:ViaService" = "s3.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Lambda Execution Role
#------------------------------------------------------------------------------

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-${var.environment}-lambda-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-execution"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
