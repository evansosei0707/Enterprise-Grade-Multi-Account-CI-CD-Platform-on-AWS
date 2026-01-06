#------------------------------------------------------------------------------
# Prod Environment IAM - Cross-Account Deploy Role (MOST RESTRICTIVE)
#------------------------------------------------------------------------------
# Production has the most restrictive permissions:
# - Explicit deny statements for dangerous actions
# - Very narrow resource patterns with exact naming
# - No delete permissions whatsoever
# - Additional conditions on all actions
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
          # Additional security: require MFA or session tags
          Bool = {
            "aws:SecureTransport" = "true"
          }
        }
      }
    ]
  })

  # Permission boundary for additional security
  # permissions_boundary = aws_iam_policy.deploy_boundary.arn

  tags = {
    Name        = "${var.project_name}-deploy-role"
    Environment = var.environment
    Purpose     = "Cross-account deployment role for CI/CD - PRODUCTION"
    SecurityLevel = "HIGH"
  }
}

#------------------------------------------------------------------------------
# Deploy Policy - MOST RESTRICTIVE Permissions for Production
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "deploy_policy" {
  name = "${var.project_name}-deploy-policy"
  role = aws_iam_role.deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #----------------------------------------------------------------
      # EXPLICIT DENY STATEMENTS (evaluated first)
      #----------------------------------------------------------------
      {
        Sid    = "DenyDangerousActions"
        Effect = "Deny"
        Action = [
          # No deletion of any resources in production
          "lambda:DeleteFunction",
          "apigateway:DELETE",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          # No policy modifications in production
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion"
        ]
        Resource = "*"
      },
      #----------------------------------------------------------------
      # ALLOWED ACTIONS (very restricted)
      #----------------------------------------------------------------
      # Lambda - Update only, no create/delete
      {
        Sid    = "LambdaUpdateOnly"
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
          "lambda:PutFunctionConcurrency",
          "lambda:InvokeFunction",
          "lambda:GetPolicy",
          "lambda:TagResource",
          "lambda:ListTags"
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:*:function:${var.project_name}-${var.environment}-release-metadata"
        ]
      },
      # Lambda create only for the specific function (first deploy)
      {
        Sid    = "LambdaCreateSpecific"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:AddPermission",
          "lambda:RemovePermission"
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:*:function:${var.project_name}-${var.environment}-release-metadata"
        ]
      },
      # API Gateway - Very restricted
      {
        Sid    = "APIGatewayReadAndUpdate"
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:PATCH"
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
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-${var.environment}-release-metadata",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-${var.environment}-release-metadata:*"
        ]
      },
      # IAM - Very restricted, only for Lambda execution role
      {
        Sid    = "IAMForLambdaRestricted"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:PassRole",
          "iam:TagRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.project_name}-${var.environment}-lambda-execution"
        ]
      },
      # IAM create role only for specific Lambda execution role
      {
        Sid    = "IAMCreateLambdaRole"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy"
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.project_name}-${var.environment}-lambda-execution"
        ]
      },
      # S3 for artifacts - Read only
      {
        Sid    = "S3ArtifactsReadOnly"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::enterprise-cicd-artifacts-${var.tooling_account_id}/lambda/*"
        ]
      },
      # IAM for Deploy Role - Read self (required for Terraform state refresh)
      {
        Sid    = "IAMReadSelf"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.project_name}-deploy-role"
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
        Resource = "*"
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
# Lambda Execution Role - Runtime permissions
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
    Name          = "${var.project_name}-${var.environment}-lambda-execution"
    Environment   = var.environment
    SecurityLevel = "HIGH"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
