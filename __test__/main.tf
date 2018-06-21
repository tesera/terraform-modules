locals {
  aws_region = "ca-central-1"
  name       = "tesera-modules-test"
}


provider "aws" {
  region  = "${local.aws_region}"
  profile = "tesera"
}

provider "aws" {
  region  = "us-east-1"
  profile = "tesera"
  alias   = "edge"
}

module "vpc" {
  source = "../vpc"
  name   = "${local.name}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${module.vpc.id}"
  service_name      = "com.amazonaws.${local.aws_region}.s3"
  route_table_ids   = ["${module.vpc.private_route_table_ids}"]
}


/*
output "private_subnet_ids" {
  value = ["${module.private_a.id}","${module.private_b.id}"]
}
*/
