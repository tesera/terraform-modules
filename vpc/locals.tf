data "aws_availability_zones" "available" {}

data "external" "public_cidr" {
  program = [
    "node",
    "${path.module}/locals-public_cidr.js",
    "${var.cidr_block}",
    "${local.az_count}",
  ]
}

data "external" "private_cidr" {
  program = [
    "node",
    "${path.module}/locals-private_cidr.js",
    "${var.cidr_block}",
    "${local.az_count}",
  ]
}

module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

# For asg
module "defaults_nat" {
  source = "../defaults"
  name   = "${var.name}-nat"
  tags   = "${var.default_tags}"
}

locals {
  account_id   = "${module.defaults.account_id}"
  region       = "${module.defaults.region}"
  name         = "${module.defaults.name}"
  tags         = "${module.defaults.tags}"
  cidr_block   = "${var.cidr_block}"
  az_count     = "${min(max(1, var.az_count), length(data.aws_availability_zones.available.names))}"
  az_name      = "${data.aws_availability_zones.available.names}"
  public_cidr  = "${data.external.public_cidr.result}"
  private_cidr = "${data.external.private_cidr.result}"
}
