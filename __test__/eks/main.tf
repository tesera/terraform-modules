locals {
  aws_region = "ca-central-1"
  profile    = "tesera"
  name       = "tesera-modules-test"
  key_name   = "${aws_key_pair.root_public_key.key_name}"
}


resource "aws_key_pair" "root_public_key" {
  key_name   = "root_public_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAH2FG5gb0RXUiyXM4qMPf4nTRXYdJ1vJWkfHIRDXHpHrxSCvDBg0QhEdZhFTnA9oTZQz/WqVfmZYriReK/c9F2zN8HbCYEi201RNwGEXjH251iBoHuxJi9O4VP9SjUbDx4vCOwQRoX+0tZWoZg7ILM2Pfb9NADFC5bSX1uqw4tDeoOMTgxHJSDhPVbuveAvzylsAZcK6sUvk9PxKfhzDDcB7CB4AuyKcgc73AZJUxn0wlTZHC4/T93DaIyFLGOCRX9TM+RwiWX4DPqYFKsHi6nLj9fbnDs8Qm8IZbrwiCaqVmzoQvqW6ltwL8JzwHq8GRmAh308nUZN8tiCaE/IiAzC7+sB3E5m29cXJSvuyPL4PxIEmYNTPNoX00Srhe8yjHnm3FwpEOjzaHYfXxgJ2xOeCFitfg5VfuHLQ6V2Vm4rvB76E7atuTAuHKHlO6YZkCbWq5Wjdzsbo6lRZPu+EAl2Y4SluMVroZZs3kShZCSrfRuTJo5jU36oQ/kTO9AicWOVo3HHCooCGa+9yFoeF9jNwCFQW8Z0a6t0PeqZ9/ntyY+RWo7zm1sREsWb9jBmFC85Iiw6J4xE5bgVVlr7mkmdvI27GLnSCkhzz3t4aH/DiUxCsQFlinRq+Io9f5/jlRKPJWkp8TxbhU6xCP2NcFqygXn3BzybKftrgMSeaF3Q== will Farrell's MacBook Pro"
}

provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.profile}"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${local.profile}"
  alias   = "edge"
}

# VPC
module "vpc" {
  source       = "../../vpc"
  name         = "${local.name}"
  az_count     = "1"
  cidr_block   = "20.5.0.0/16"
  nat_type     = "instance"
  default_tags = "${map(
    "kubernetes.io/cluster/${module.eks.name}", "shared"
  )}"
}

module "eks" {
  source             = "../../eks"
  name               = "${local.name}"
  vpc_id             = "${module.vpc.id}"
  private_subnet_ids = "${module.vpc.public_subnet_ids}"
  key_name           = "${local.key_name}"
}
