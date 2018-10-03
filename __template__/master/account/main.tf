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
  name          = "${var.name}2"
  roles         = [
    "admin",
    "developer"]
  sub_accounts  = [
    "production"]
  account_email = "${var.account_email}"
}

# Users
module "user" {
  source        = "../../../user"
  name          = "${var.name}"
  account_email = "${var.account_email}"
  pgp_key_path  = "${path.module}/terraform.pub"
  email         = "will.farrell@tesera.com"
  groups        = [
    "MasterTerraform",
    "MasterAdmin",
    "ProductionAdmin"]
}
