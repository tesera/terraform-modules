resource "aws_subnet" "main" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${var.cidr_block}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "private-${var.name}-${var.availability_zone}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.gateway_id}"
  }

  tags {
    Name = "private-${var.name}-${var.availability_zone}"
  }
}
resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

