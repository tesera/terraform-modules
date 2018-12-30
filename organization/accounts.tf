// master
// |- ou-operations
// |  |- operations
// |  |- forensics
// |- ou-environments
// |  |- production
// |  |- staging
// |  |- testing
// |  |- development
//resource "aws_organizations_organization" "account" {
//  feature_set = "ALL"
//}
// TODO loop over local.subaccounts
// Docs: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create.html
// To set password go to root sign up and enter email
//resource "aws_organizations_account" "main" {
//  count                      = "${length(var.sub_accounts)}"
//  name                       = "${var.sub_accounts[count.index]}"
//  email                      = "${local.account_email_local_part}+${var.sub_accounts[count.index]}@${local.account_email_domain}"
//  iam_user_access_to_billing = "DENY"
//}
# Org Units - TODO https://github.com/terraform-providers/terraform-provider-aws/pull/4207
// https://www.terraform.io/docs/providers/aws/r/organizations_policy_attachment.html
//resource "aws_organizations_policy_attachment" "environments" {
//  policy_id = "${aws_organizations_policy.environments.id}"
//  target_id = "ou-12345678"
//}
//
//resource "aws_organizations_policy" "environments" {
//  name    = "org-environments-policy"
//
//  content = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": {
//    "Effect": "Allow",
//    "Action": "*",
//    "Resource": "*"
//  }
//}
//POLICY
//}

