# Uncomment assume_role after roles have been setup
terraform {
  backend "s3" {
    bucket         = "terraform-state-${var.name}"
    key            = "environment/account/terraform.tfstate"
    region         = "us-east-1"
    profile        = "${var.state_profile}"
    dynamodb_table = "terraform-state-${var.name}"
  }
}

data "terraform_remote_state" "master" {
  backend = "s3"
  config = {
    bucket         = "terraform-state-${var.name}"
    key            = "master/account/terraform.tfstate"
    region         = "us-east-1"
    profile        = "${var.state_profile}"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.profile}"
  /*assume_role = {
    role_arn = "arn:aws:iam::*:role/admin"
  }*/
}



module "account" {
  source = "../../../sub-account"
  name   = "${var.name}"
  master_account_id = "${data.terraform_remote_state.master.account_id}"
  roles  = [
    "admin",
    "developer"]
}

output "account_id" {
  value = "${module.account.id}"
}

output "roles" {
  value = "${module.account.roles}"
}
