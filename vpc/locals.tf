data "external" "az_name" {
  program = [
    "node",
    "${path.module}/locals-az_name.js",
    "${var.az_count}"]
}

data "external" "public_cidr" {
  program = [
    "node",
    "${path.module}/locals-public_cidr.js",
    "${var.cidr_block}",
    "${var.az_count}"]
}

data "external" "private_cidr" {
  program = [
    "node",
    "${path.module}/locals-private_cidr.js",
    "${var.cidr_block}",
    "${var.az_count}"]
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
  az_count     = "${var.az_count > 1 ? var.az_count : 1}"
  az_name      = "${data.external.az_name.result}"
  public_cidr  = "${data.external.public_cidr.result}"
  private_cidr = "${data.external.private_cidr.result}"
}
