resource "aws_subnet" "main" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${var.cidr_block}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "public-${var.name}-${var.availability_zone}"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags {
    key                 = "Name"
    value               = "${var.name}-${var.availability_zone}"
  }

  tags {
    key                 = "Terraform"
    value               = "true"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.main.id}"
}


resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${var.route_table_id}"
}
