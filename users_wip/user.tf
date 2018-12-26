# User
resource "aws_iam_user" "user" {
  count         = "${length(keys(var.users))}"
  name          = "${element(split("@", element(keys(var.users),count.index)), 0)}"
  force_destroy = true
}

resource "aws_iam_user_group_membership" "user" {
  count  = "${length(keys(var.users))}"
  user   = "${aws_iam_user.user.*.name[count.index]}"

  groups = [
    "${concat(list("User"), var.users[element(keys(var.users),count.index)])}"
  ]
}


resource "aws_iam_user_login_profile" "user" {
  count           = "${ (var.pgp_key_path == "" || var.account_email == "") ? 0 : length(keys(var.users)) }"
  user            = "${aws_iam_user.user.*.name[count.index]}"
  pgp_key         = "${file(var.pgp_key_path)}"
  password_length = "${local.minimum_password_length}"
}

resource "null_resource" "users" {
  count = "${ (var.pgp_key_path == "" || var.account_email == "") ? 0 : length(keys(var.users)) }"

  triggers {
    encrypted_password = "${aws_iam_user_login_profile.user.*.encrypted_password[count.index]}"
  }

  provisioner "local-exec" {
    # $ alias admin_email user_email user_name encrypted_password
    command = "${path.module}/send-email.sh '${local.account_alias}' '${var.account_email}' '${element(keys(var.users),count.index)}' '${aws_iam_user.user.*.name[count.index]}' '${aws_iam_user_login_profile.user.*.encrypted_password[count.index]}'"
  }
}


# TODO - ssh https://www.terraform.io/docs/providers/aws/r/iam_user_ssh_key.html - pull form gh




