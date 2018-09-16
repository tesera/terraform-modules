resource "aws_vpc" "main" {
  cidr_block           = "${local.cidr_block}"
  enable_dns_hostnames = true
  #assign_generated_ipv6_cidr_block = true

  tags = "${merge(local.tags, map(
    "Name", "${local.name}"
  ))}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(local.tags, map(
    "Name", "${local.name}"
  ))}"
}

resource "aws_default_route_table" "r" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  tags = "${merge(local.tags, map(
    "Name", "default-${local.name}"
  ))}"
}
