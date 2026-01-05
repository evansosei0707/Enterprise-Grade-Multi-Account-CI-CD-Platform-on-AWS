#------------------------------------------------------------------------------
# KMS Module Outputs
#------------------------------------------------------------------------------

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_alias_arn" {
  description = "ARN of the KMS key alias"
  value       = aws_kms_alias.main.arn
}
