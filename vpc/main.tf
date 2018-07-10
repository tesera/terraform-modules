resource "aws_vpc" "main" {
  cidr_block           = "${local.cidr_block}"
  enable_dns_hostnames = true
  #assign_generated_ipv6_cidr_block = true

  tags {
    Name      = "${var.name}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name      = "${var.name}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
