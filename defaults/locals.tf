data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

locals {
  account_id        = data.aws_caller_identity.current.account_id
  profile           = data.aws_caller_identity.current.user_id
  region            = data.aws_region.current.name
  name              = replace(var.name, "/[^a-zA-Z0-9-]/", "-")
  name_alphanumeric = replace(var.name, "/[^a-zA-Z0-9]/", "")
  # Sanitize name, waf labels follow different rules

  tags = merge(
    {
      Terraform   = true
      Environment = terraform.workspace
      Name        = replace(var.name, "/[^a-zA-Z0-9-]/", "-")
      Description = ""
    },
    var.tags,
  )
}

