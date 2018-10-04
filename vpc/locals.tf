data "aws_availability_zones" "available" {}

data "external" "az_name" {
  program = [
    "node",
    "${path.module}/locals-az_name.js",
    "${local.az_count}",
    "${data.aws_availability_zones.available.count}"]
}

data "external" "public_cidr" {
  program = [
    "node",
    "${path.module}/locals-public_cidr.js",
    "${var.cidr_block}",
    "${local.az_count}",
    "${data.aws_availability_zones.available.count}"]
}

data "external" "private_cidr" {
  program = [
    "node",
    "${path.module}/locals-private_cidr.js",
    "${var.cidr_block}",
    "${local.az_count}",
    "${data.aws_availability_zones.available.count}"]
}

module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  account_id   = "${module.defaults.account_id}"
  aws_region   = "${module.defaults.aws_region}"
  name         = "${module.defaults.name}"
  tags         = "${module.defaults.tags}"
  cidr_block   = "${var.cidr_block}"
  az_max       = "${data.aws_availability_zones.available.count}"
  az_count     = "${var.az_count > 1 ? var.az_count : 1}"
  az_name      = "${data.external.az_name.result}"
  public_cidr  = "${data.external.public_cidr.result}"
  private_cidr = "${data.external.private_cidr.result}"
}
