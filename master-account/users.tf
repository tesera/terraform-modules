# Users
resource "aws_iam_user" "users" {
  count         = "${length(keys(var.users))}"
  name          = "${element(split("@",element(keys(var.users), count.index)),0)}"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "users" {
  count           = "${length(aws_iam_user.users.*.name)}"
  user            = "${aws_iam_user.users.*.name[count.index]}"
  pgp_key         = "${file(var.pgp_key_path)}"
  password_length = "${local.minimum_password_length}"
}

resource "null_resource" "users" {
  count           = "${length(aws_iam_user.users.*.name)}"

  triggers {
    encrypted_password = "${aws_iam_user_login_profile.users.*.encrypted_password[count.index]}"
  }

  provisioner "local-exec" {
    # $ alias admin_email user_email user_name encrypted_password
    command = "${path.module}/send-email.sh '${aws_iam_account_alias.alias.account_alias}' '${var.account_email}' '${element(keys(var.users), count.index)}' '${aws_iam_user.users.*.name[count.index]}' '${aws_iam_user_login_profile.users.*.encrypted_password[count.index]}'"
  }
}

resource "aws_iam_user_group_membership" "users" {
  count  = "${length(keys(var.users))}"
  user   = "${aws_iam_user.users.*.name[count.index]}"

  groups = [
    "${concat(list("User"),split(",",element(values(var.users), count.index)))}"]
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
