resource "aws_subnet" "private" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${local.private_cidr[count.index]}"
  availability_zone = "${local.aws_region}${local.az_name[count.index]}"

  tags {
    Name      = "private-${var.name}-${local.aws_region}${local.az_name[count.index]}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  count  = "${local.az_count}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.public.*.id[count.index]}"
  }

  tags {
    Name      = "private-${var.name}-${local.aws_region}${local.az_name[count.index]}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
resource "aws_route_table_association" "private" {
  count          = "${local.az_count}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}

