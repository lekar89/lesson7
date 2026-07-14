resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  deletion_protection_enabled = true

  tags = merge(
    {
      Name      = var.dynamodb_table_name
      ManagedBy = "Terraform"
    },
    var.tags
  )
}