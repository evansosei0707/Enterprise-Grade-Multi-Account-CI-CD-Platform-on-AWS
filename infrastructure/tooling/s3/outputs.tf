#------------------------------------------------------------------------------
# S3 Module Outputs
#------------------------------------------------------------------------------

output "terraform_state_bucket_id" {
  description = "ID of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "artifacts_bucket_id" {
  description = "ID of the artifacts bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "artifacts_bucket_domain_name" {
  description = "Domain name of the artifacts bucket"
  value       = aws_s3_bucket.artifacts.bucket_regional_domain_name
}
