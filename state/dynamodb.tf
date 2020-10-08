resource "aws_dynamodb_table" "main" {
  name           = "terraform-state${local.name}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name      = "Terraform Remote State"
    Terraform = true
    Security  = "SSE:AWS"
  }
}

