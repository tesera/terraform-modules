resource "aws_dynamodb_table" "main" {
  name           = "terraform-state${local.name}"
  billing_mode = "PAY_PER_REQUEST"
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

  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }

  tags = {
    Name      = "Terraform Remote State"
    Terraform = true
    Security  = "SSE:AWS"
  }
}

