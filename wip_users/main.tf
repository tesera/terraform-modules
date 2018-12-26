
resource "aws_iam_account_alias" "alias" {
  count = "${var.account_alias == "" ? 0 : 1}"
  account_alias = "${var.account_alias}"
}

# Entropy FTW - https://xkcd.com/936/
/*resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = false
  password_reuse_prevention      = false
  minimum_password_length        = "${local.minimum_password_length}"
  require_lowercase_characters   = false
  require_uppercase_characters   = false
  require_numbers                = false
  require_symbols                = false
}*/

# PGP
//resource "local_file" "pubkey" {
//  content  = ""
//  filename = "${path.module}/terraform.pub"
//}
//data "local_file" "pubkey" {
//  filename   = "${path.module}/terraform.pub"
//  depends_on = ["local_file.pubkey"]
//}
//resource "null_resource" "pubkey" {
//  triggers = {
//    pubkey = "${data.local_file.pubkey.content}"
//  }
//  provisioner "local-exec" {
//    command = "gpg --export ${local.account_id} | base64 > ${path.module}/terraform.pub"
//  }
//}
