terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "environment/app/terraform.tfstate"
    region         = "us-east-1"
    profile        = "tesera"
    dynamodb_table = "terraform-state"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.profile}"
  assume_role = {
    role_arn = "arn:aws:iam::*:role/admin"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.profile}"
  alias   = "edge"
  assume_role = {
    role_arn = "arn:aws:iam::*:role/admin"
  }
}

## States
//data "terraform_remote_state" "vpc" {
//  backend = "s3"
//
//  config {
//    bucket  = "terraform-state"
//    key     = "vpc/terraform.tfstate"
//    region  = "us-east-1"
//    profile = "tesera"
//  }
//}
