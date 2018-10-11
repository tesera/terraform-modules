terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket         = "terraform-state-"
    key            = "api/terraform.tfstate"
    region         = "us-east-1"
    profile        = "tesera"
    dynamodb_table = "terraform-state-"
  }
}

variable "workspace_iam_roles" {
  type = "map"
  default = {
    devemopment = "arn:aws:iam::DEVELOPMENT-ACCOUNT-ID:role/Terraform"
    testing     = "arn:aws:iam::TESTING-ACCOUNT-ID:role/Terraform"
    staging     = "arn:aws:iam::STAGING-ACCOUNT-ID:role/Terraform"
    production  = "arn:aws:iam::PRODUCTION-ACCOUNT-ID:role/Terraform"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.profile}"
  assume_role = "${var.workspace_iam_roles[terraform.workspace]}"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.profile}"
  alias   = "edge"
  assume_role = "${var.workspace_iam_roles[terraform.workspace]}"
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

## API
