data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

locals {
  account_id   = "${data.aws_caller_identity.current.account_id}"
  aws_region   = "${data.aws_region.current.name}"
  cidr_block   = "${var.cidr_block}"
  az_count     = "${var.az_count > 1 ? var.az_count : 1}"
  az_name      = "${data.external.az_name.result}"
  public_cidr  = "${data.external.public_cidr.result}"
  private_cidr = "${data.external.private_cidr.result}"
}
