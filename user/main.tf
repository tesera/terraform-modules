
# Users
resource "aws_iam_user" "user" {
  name          = "${element(split("@",var.email),0)}"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "user" {
  user            = "${aws_iam_user.user.name}"
  pgp_key         = "${file(var.pgp_key_path)}"
  password_length = "${local.minimum_password_length}"
}

resource "null_resource" "users" {

  triggers {
    encrypted_password = "${aws_iam_user_login_profile.user.encrypted_password}"
  }

  provisioner "local-exec" {
    # $ alias admin_email user_email user_name encrypted_password
    command = "${path.module}/send-email.sh '${local.account_alias}' '${var.account_email}' '${var.email}' '${aws_iam_user.user.name}' '${aws_iam_user_login_profile.user.encrypted_password}'"
  }
}

resource "aws_iam_user_group_membership" "user" {
  user   = "${aws_iam_user.user.name}"

  groups = [
    "${concat(list("User"),var.groups)}"
  ]
}

# TODO - ssh https://www.terraform.io/docs/providers/aws/r/iam_user_ssh_key.html - pull form gh

# Entropy FTW - https://xkcd.com/936/
resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = false
  password_reuse_prevention      = false
  minimum_password_length        = "${local.minimum_password_length}"
  require_lowercase_characters   = false
  require_uppercase_characters   = false
  require_numbers                = false
  require_symbols                = false
}




