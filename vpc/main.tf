variable "aws_region" {
  type    = "string"
  default = "us-west-2"
}

variable "env" {
  type = "string"
}

variable "tenant" {
  type = "string"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.tenant}-${var.env}"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.tenant}-${var.env}"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_a.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "public-${var.tenant}-${var.env}"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "public-${var.tenant}-${var.env}-a"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "public_b" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "public-${var.tenant}-${var.env}-b"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.main.id}"
  }

  tags {
    Name = "private-${var.tenant}-${var.env}"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.10.0/24"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "private-${var.tenant}-${var.env}-a"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_subnet" "private_b" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.15.0/24"
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "private-${var.tenant}-${var.env}-b"
    Tenant = "${var.tenant}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_security_group" "elasticbeanstalk" {
  name   = "elasticbeanstalk-${var.tenant}-${var.env}-app-ec2"
  vpc_id = "${aws_vpc.main.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name   = "elasticbeanstalk-${var.tenant}-${var.env}-rds"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elasticbeanstalk.id}"]
  }

  # This allows you to ignore change to the security group
  # In this case, home ips
  lifecycle {
    ignore_changes = ["ingress"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis" {
  name   = "elasticbeanstalk-${var.tenant}-${var.env}-app-redis"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elasticbeanstalk.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# This allows lambda to connect to s3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${aws_vpc.main.id}"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = ["${aws_route_table.private.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public_a.id},${aws_subnet.public_b.id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private_a.id},${aws_subnet.private_b.id}"
}

output "elasticbeanstalk_security_group_id" {
  value = "${aws_security_group.elasticbeanstalk.id}"
}

output "rds_security_group_id" {
  value = "${aws_security_group.rds.id}"
}

output "redis_security_group_id" {
  value = "${aws_security_group.redis.id}"
}
