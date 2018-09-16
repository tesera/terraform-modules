resource "aws_subnet" "private" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${local.private_cidr[count.index]}"
  availability_zone = "${local.aws_region}${local.az_name[count.index]}"

  tags = "${merge(local.tags, map(
    "Name", "private-${local.name}-az-${local.az_name[count.index]}"
  ))}"
}

# route_table is handled by the NAT
