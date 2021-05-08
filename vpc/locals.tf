data "aws_availability_zones" "available" {
}

module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  account_id = module.defaults.account_id
  region     = module.defaults.region
  name       = module.defaults.name
  tags       = module.defaults.tags
  cidr_block = var.cidr_block
  az_count = min(
    max(1, var.az_count),
    length(data.aws_availability_zones.available.names)
  )
  az_name = data.aws_availability_zones.available.names
  #   TODO: make use of the cidrsubnet function
  public_cidr  = [for name in local.az_name : "${replace(var.cidr_block, ".0.0/16", "")}.${index(local.az_name, name)}.0/24"]
  private_cidr = [for name in local.az_name : "${replace(var.cidr_block, ".0.0/16", "")}.${(index(local.az_name, name) + 1) * 16}.0/20"]
}

