resource "aws_vpc" "main" {
  cidr_block           = "${local.cidr_block}"
  enable_dns_hostnames = true
  #assign_generated_ipv6_cidr_block = true

  tags {
    Name      = "${var.name}"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name      = "${var.name}"
    Terraform = "true"
  }
}

# Public Subnets



# Avalibility Zones

# Zone A
//module "public_a" {
//  source            = "./modules/public_subnet"
//  name              = "${var.name}"
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "10.0.10.0/24"
//  availability_zone = "${local.aws_region}a"
//  route_table_id    = "${aws_route_table.public.id}"
//}

//module "private_a" {
//  source            = "./modules/private_subnet"
//  name              = "${var.name}"
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "10.0.11.0/24"
//  availability_zone = "${local.aws_region}a"
//  gateway_id        = "${module.public_a.gateway_id}"
//}

# Zone B
//module "public_b" {
//  source            = "./modules/public_subnet"
//  name              = "${var.name}"
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "10.0.20.0/24"
//  availability_zone = "${local.aws_region}b"
//  route_table_id    = "${aws_route_table.public.id}"
//}

//module "private_b" {
//  source            = "./modules/private_subnet"
//  name              = "${var.name}"
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "10.0.21.0/24"
//  availability_zone = "${local.aws_region}b"
//  gateway_id        = "${module.public_b.gateway_id}"
//}

# Zone C
# module count not supported - https://github.com/hashicorp/terraform/issues/953
//module "public" {
//  count             = "${local.az_count}"
//  source            = "./modules/public_subnet"
//  name              = "${var.name}"
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "${lookup(local.public_cidr, count.index)}"
//  availability_zone = "${local.aws_region}${lookup(local.az_name, count.index)}"
//  route_table_id    = "${aws_route_table.public.id}"
//}
//
//module "private" {
//  count             = "${local.az_count}"
//  source            = "./modules/private_subnet"
//  name              = "${var.name}"
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "${lookup(local.private_cidr, count.index)}"
//  availability_zone = "${local.aws_region}${lookup(local.az_name, count.index)}"
//  gateway_id        = "${module.public[count.index].gateway_id}"
//}
