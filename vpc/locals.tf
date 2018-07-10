data "aws_region" "current" {}

locals {
  aws_region = "${data.aws_region.current.name}"
  az_count = "${var.az_count > 2 ? var.az_count : 2}"
  az_name = {
    "0" = "a"
    "1" = "b"
    "2" = "c"
    "3" = "d"
    "4" = "e"
    "5" = "f" # us-east-1 has 6 AZ 2018-07
  }
  cidr_block = "${var.cidr_block}"
  public_cidr = {
    "0" = "${replace(var.cidr_block, ".0.0/16", "")}.10.0/24"
    "1" = "${replace(var.cidr_block, ".0.0/16", "")}.20.0/24"
    "2" = "${replace(var.cidr_block, ".0.0/16", "")}.30.0/24"
    "3" = "${replace(var.cidr_block, ".0.0/16", "")}.40.0/24"
    "4" = "${replace(var.cidr_block, ".0.0/16", "")}.50.0/24"
    "5" = "${replace(var.cidr_block, ".0.0/16", "")}.60.0/24"
  }
  private_cidr = {
    "0" = "${replace(var.cidr_block, ".0.0/16", "")}.11.0/24"
    "1" = "${replace(var.cidr_block, ".0.0/16", "")}.21.0/24"
    "2" = "${replace(var.cidr_block, ".0.0/16", "")}.31.0/24"
    "3" = "${replace(var.cidr_block, ".0.0/16", "")}.41.0/24"
    "4" = "${replace(var.cidr_block, ".0.0/16", "")}.51.0/24"
    "5" = "${replace(var.cidr_block, ".0.0/16", "")}.61.0/24"
  }
}
