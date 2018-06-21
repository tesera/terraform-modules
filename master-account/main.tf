provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_default_region}"
  shared_credentials_file = "~/.aws/credentials"
  allowed_account_ids = ["${var.aws_account_id}"]
}

resource "aws_organizations_organization" "account" {
  feature_set = "ALL"
}

# NOTE: Must request from support tpo up the lomit for Ogranizations / Number of Accounts




