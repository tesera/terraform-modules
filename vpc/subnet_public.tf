resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name      = "public-${var.name}-${local.aws_region}"
    Terraform = "true"
  }
}

resource "aws_subnet" "public" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${local.public_cidr[count.index]}"
  availability_zone = "${local.aws_region}${local.az_name[count.index]}"

  tags {
    Name      = "public-${var.name}-${local.aws_region}${local.az_name[count.index]}"
    Terraform = "true"
  }
}

resource "aws_eip" "nat" {
  count = "${local.az_count}"
  vpc   = true

  tags {
    Name      = "${var.name}-${local.aws_region}${local.az_name[count.index]}"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "public" {
  count         = "${local.az_count}"
  allocation_id = "${aws_eip.nat.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"

  tags {
    Name      = "${var.name}-${local.aws_region}${local.az_name[count.index]}"
    Terraform = "true"
  }
}


resource "aws_route_table_association" "public" {
  count          = "${local.az_count}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}
