
# gateway
resource "aws_route_table" "private-gateway" {
  count  = "${var.nat_type == "gateway" ? local.az_count : 0}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.public.*.id[count.index]}"
  }

  tags = "${merge(local.tags, map(
    "Name", "private-${local.name}-az-${local.az_name[count.index]}"
  ))}"
}

resource "aws_route_table_association" "private-gateway" {
  count          = "${var.nat_type == "gateway" ? local.az_count : 0}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private-gateway.*.id[count.index]}"
}

# gateway
resource "aws_nat_gateway" "public" {
  count         = "${var.nat_type == "gateway" ? local.az_count : 0}"
  allocation_id = "${aws_eip.nat.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"

  tags = "${merge(local.tags, map(
    "Name", "${local.name}-az-${local.az_name[count.index]}"
  ))}"
}
