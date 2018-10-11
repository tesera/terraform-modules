terraform {
  backend "s3" {
    bucket         = "terraform-state-${var.name}"
    key            = "master/account/terraform.tfstate"
    region         = "us-east-1"
    profile        = "${var.profile}"
    dynamodb_table = "terraform-state-${var.name}"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.profile}"
}

module "account" {
  source        = "../../../master-account"
  account_alias = "${var.account_alias}"
  roles         = [
    "admin",
    "developer"]
  sub_accounts  = [
    "production"]
  account_email = "${var.account_email}"
}
