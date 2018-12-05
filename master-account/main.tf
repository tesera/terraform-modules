# resource "aws_organizations_organization" "account" {
#   feature_set = "ALL"
# }

resource "aws_iam_account_alias" "alias" {
  count         = "${var.account_alias == "" ? 0 : 1}"
  account_alias = "${var.account_alias}"
}
