#------------------------------------------------------------------------------
# DynamoDB Module - Terraform State Locking
#------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Enable point-in-time recovery for safety
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name    = "${var.project_name}-terraform-locks"
    Purpose = "Terraform State Locking"
  }
}
