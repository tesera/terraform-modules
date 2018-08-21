//terraform {
//  backend "s3" {
//    bucket         = "terraform-state"
//    key            = "vpc/terraform.tfstate"
//    region         = "ca-central-1"
//    profile        = "tesera"
//    dynamodb_table = "terraform-state"
//  }
//}

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
  source     = "../../vpc"
  name       = "${local.name}"
  az_count   = "1"
  cidr_block = "20.5.0.0/16"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "private_subnet_ids" {
  value = "${module.vpc.private_subnet_ids}"
}

## Public Subnets
### Bastion
module "bastion" {
  source            = "../../bastion"
  name              = "${local.name}"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.vpc.public_subnet_ids}"
  key_name          = "${local.key_name}"
  iam_user_groups   = "Admin"
}

output "bastion_ip" {
  value = "${module.bastion.public_ip}"
}

output "bastion_billing_suggestion" {
  value = "${module.bastion.billing_suggestion}"
}

### Proxy
module "proxy" {
  source                    = "../../proxy"
  name                      = "${local.name}"
  vpc_id                    = "${module.vpc.id}"
  public_subnet_ids         = "${module.vpc.public_subnet_ids}"
  key_name                  = "${local.key_name}"
  iam_user_groups           = "Admin"
  iam_sudo_groups           = "Admin"
  proxy_name                = "postgres"
  proxy_endpoint            = "${module.rds.endpoint}"
  proxy_port                = "5432"
  bastion_security_group_id = "${module.bastion.security_group_id}"
}

resource "aws_security_group_rule" "proxy-public" {
  security_group_id = "${module.proxy.security_group_id}"
  type              = "ingress"
  from_port         = "5432"
  to_port           = "5432"
  protocol          = "tcp"
  cidr_blocks       = [
    "0.0.0.0/0"]
}

output "proxy_ip" {
  value = "${module.proxy.public_ip}"
}

output "proxy_billing_suggestion" {
  value = "${module.proxy.billing_suggestion}"
}

## Private Subnets
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${module.vpc.id}"
  service_name    = "com.amazonaws.${local.aws_region}.s3"
  route_table_ids = [
    "${module.vpc.private_route_table_ids}"]
}

### Docker Cluster
//module "ecs" {
//  source             = "../../ecs"
//  name               = "${local.name}"
//  vpc_id             = "${module.vpc.id}"
//  private_subnet_ids = "${module.vpc.private_subnet_ids}"
//  key_name           = "${local.key_name}"
//  iam_user_groups    = "Admin"
//}
//
//output "ecs_name" {
//  value = "${module.ecs.name}"
//}
//
//output "ecs_billing_suggestion" {
//  value = "${module.ecs.billing_suggestion}"
//}

### Database
module "rds" {
  source                    = "../../rds"
  name                      = "${local.name}"
  db_name                   = "dbname"
  username                  = "dbuser"
  password                  = "dbpassword"
  parameter_group_name      = ""
  vpc_id                    = "${module.vpc.id}"
  private_subnet_ids        = [
    "${module.vpc.private_subnet_ids}"]
  bastion_security_group_id = "${module.bastion.security_group_id}"
}

resource "aws_security_group_rule" "rds-proxy" {
  security_group_id        = "${module.rds.security_group_id}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${module.proxy.security_group_id}"
}

output "rds_billing_suggestion" {
  value = "${module.rds.billing_suggestion}"
}
