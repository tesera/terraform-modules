resource "aws_eip" "nat" {
  count = "${local.az_count}"
  vpc   = true

  tags {
    Name      = "${var.name}-az-${local.az_name[count.index]}"
    Terraform = "true"
  }
}

# gateway
resource "aws_nat_gateway" "public" {
  count         = "${local.az_count}"
  allocation_id = "${aws_eip.nat.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"

  tags {
    Name      = "${var.name}-az-${local.az_name[count.index]}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

# instance

