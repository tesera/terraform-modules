
//resource "aws_organizations_account" "operations" {
//  name  = "operations"
//  email = "${var.account_email_local_part}+operations@${var.account_email_domain}"
//  iam_user_access_to_billing = "ALLOW"
//}

resource "aws_organizations_account" "forensics" {
  name  = "forensics"
  email = "${var.account_email_local_part}+forensics@${var.account_email_domain}"
  iam_user_access_to_billing = "ALLOW"
}
