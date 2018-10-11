terraform {
  backend "s3" {
    bucket         = "terraform-state-"
    key            = "db/terraform.tfstate"
    region         = "us-east-1"
    profile        = "tesera"
    dynamodb_table = "terraform-state-"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.profile}"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.profile}"
  alias   = "edge"
}

## States
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket  = "terraform-state"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "${var.profile}"
  }
}

## Database(s)
module "rds" {
  source = "git@github.com:tesera.com/terraform-modules//rds"
  name = "${var.name}"
  db_name = "dbname"
  username = "dbuser"
  password = "dbpassword"
  parameter_group_name = ""
  vpc_id = "${data.terraform_remote_state.vpc.id}"
  private_subnet_ids = ["${data.terraform_remote_state.vpc.private_subnet_ids}"]
}

resource "aws_security_group_rule" "rds" {
  security_group_id        = "${module.rds.security_group_id}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${module.rds.security_group_id}"
}

output "rds_billing_suggestion" {
  value = "${module.rds.billing_suggestion}"
}
