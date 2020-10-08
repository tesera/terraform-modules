module "defaults" {
  source = "../defaults"
  name   = "${var.name}-bastion"
  tags   = var.default_tags
}

locals {
  account_id    = module.defaults.account_id
  region        = module.defaults.region
  tags          = module.defaults.tags
  name          = replace(module.defaults.name, "/[_]/", "-")
  sse_algorithm = "AES256"

  logging_bucket = var.logging_bucket != "" ? var.logging_bucket : "${module.defaults.name}-${terraform.workspace}-edge-logs"
}

