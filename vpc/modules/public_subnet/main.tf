resource "aws_subnet" "main" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.cidr_block}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name      = "public-${var.name}-${var.availability_zone}"
    Terraform = "true"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name      = "${var.name}-${var.availability_zone}"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.main.id}"

  tags {
    Name      = "${var.name}-${var.availability_zone}"
    Terraform = "true"
  }
}


resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${var.route_table_id}"
}
