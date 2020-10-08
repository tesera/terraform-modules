module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  account_id      = module.defaults.account_id
  region          = module.defaults.region
  name            = module.defaults.name
  tags            = module.defaults.tags
  assume_role_arn = var.assume_role_arn == "" ? aws_iam_role.ssh[0].arn : var.assume_role_arn
}

