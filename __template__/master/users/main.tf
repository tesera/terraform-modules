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

# Users
module "user" {
  source        = "../../../user"
  account_email = "${var.account_email}"
  pgp_key_path  = "${path.module}/terraform.pub"
  email         = "will.farrell@tesera.com"
  groups        = [
    "MasterTerraform",
    "MasterAdmin",
    "ProductionAdmin"]
}
