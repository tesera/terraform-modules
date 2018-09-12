resource "aws_subnet" "private" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${local.private_cidr[count.index]}"
  availability_zone = "${local.aws_region}${local.az_name[count.index]}"

  tags {
    Name        = "private-${var.name}-az-${local.az_name[count.index]}"
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

# route_table is handled by the NAT
