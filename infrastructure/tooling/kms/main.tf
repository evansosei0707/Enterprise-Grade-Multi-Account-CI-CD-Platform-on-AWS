#------------------------------------------------------------------------------
# KMS Module - Encryption Keys for Terraform State and Artifacts
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Key for S3 Encryption (State + Artifacts)
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = "${var.project_name} - Encryption key for state and artifacts"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.project_name}-key-policy"
    Statement = [
      # Allow root account full access (required)
      {
        Sid    = "EnableRootAccountAccess"
        Effect = "Allow"
        Principal = {
          # NOTE: Using tooling_account_id which is temporarily Governance account
          AWS = "arn:aws:iam::${var.tooling_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      # Allow environment accounts to decrypt (for reading artifacts)
      {
        Sid    = "AllowEnvironmentAccountsDecrypt"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.dev_account_id}:root",
            "arn:aws:iam::${var.staging_account_id}:root",
            "arn:aws:iam::${var.prod_account_id}:root"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-kms-key"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}"
  target_key_id = aws_kms_key.main.key_id
}
