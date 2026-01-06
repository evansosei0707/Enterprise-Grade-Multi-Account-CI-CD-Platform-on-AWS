#------------------------------------------------------------------------------
# Dev Environment IAM - Cross-Account Deploy Role
#------------------------------------------------------------------------------
# This role is assumed by GitHub Actions (via Tooling account) to deploy
# resources in the Dev account. Dev has broader permissions for fast iteration.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Deploy Role - Assumed from Tooling Account
#------------------------------------------------------------------------------

resource "aws_iam_role" "deploy_role" {
  name = "${var.project_name}-deploy-role"

  # Trust policy - allows Tooling account to assume this role
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
            # Additional security: require specific role from Tooling account
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
# Deploy Policy - Permissions for Dev Environment (Broader for fast iteration)
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "deploy_policy" {
  name = "${var.project_name}-deploy-policy"
  role = aws_iam_role.deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Lambda permissions
      {
        Sid    = "LambdaManagement"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:ListFunctions",
          "lambda:InvokeFunction",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:GetPolicy",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:ListTags"
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:*:function:${var.project_name}-*"
        ]
      },
      # API Gateway permissions
      {
        Sid    = "APIGatewayManagement"
        Effect = "Allow"
        Action = [
          "apigateway:*"
        ]
        Resource = [
          "arn:aws:apigateway:${var.aws_region}::/*"
        ]
      },
      # CloudWatch Logs permissions (Read/List - Broad access required for Terraform checks)
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
      # CloudWatch Logs permissions (Write - Restricted to project)
      {
        Sid    = "CloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogStream",
          "logs:PutLogEvents",
          "logs:TagResource",
          "logs:UntagResource",
          "logs:PutRetentionPolicy"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-*:*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/api-gateway/${var.project_name}-*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/api-gateway/${var.project_name}-*:*"
        ]
      },
      # IAM permissions for Lambda execution role
      {
        Sid    = "IAMForLambda"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.project_name}-*"
        ]
      },
      # S3 permissions for reading artifacts from Tooling account
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
      # KMS permissions for decrypting artifacts
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
# Lambda Execution Role - Runtime permissions for Lambda function
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
    Purpose     = "Lambda execution role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
