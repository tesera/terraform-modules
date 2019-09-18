data "aws_availability_zones" "available" {
}

data "null_data_source" "cidr" {
  count = local.az_count
  inputs = {
    public  = "${replace(var.cidr_block, ".0.0/16", "")}.${count.index}.0/24"
    private = "${replace(var.cidr_block, ".0.0/16", "")}.${(count.index + 1) * 16}.0/20"
  }
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
  az_name      = data.aws_availability_zones.available.names
  public_cidr  = data.null_data_source.cidr.*.outputs.public
  private_cidr = data.null_data_source.cidr.*.outputs.private
}

