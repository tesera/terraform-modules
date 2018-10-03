
resource "aws_organizations_organization" "account" {
  feature_set = "ALL"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "${local.name}"
}

