module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  name = module.defaults.name
  tags = module.defaults.tags
}

