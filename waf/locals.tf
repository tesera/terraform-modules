data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  name       = replace(var.name, "/[^a-zA-Z0-9]/", "") # Sanitize name, waf labels follow different rules

  logging_bucket = var.logging_bucket != "" ? var.logging_bucket : "${replace(var.name, "/[^a-zA-Z0-9]/", "")}-${terraform.workspace}-edge-logs"
}

