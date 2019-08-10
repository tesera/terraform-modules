# User
resource "aws_iam_user" "user" {
  count         = length(keys(var.users))
  name          = element(split("@", element(keys(var.users), count.index)), 0)
  force_destroy = true
}

resource "aws_iam_user_group_membership" "user" {
  count = length(keys(var.users))
  user  = aws_iam_user.user[count.index].name

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  groups = [
    concat(["User"], var.users[element(keys(var.users), count.index)]),
  ]
}

resource "aws_iam_user_login_profile" "user" {
  count           = var.pgp_key_path == "" || var.account_email == "" ? 0 : length(keys(var.users))
  user            = aws_iam_user.user[count.index].name
  pgp_key         = file(var.pgp_key_path)
  password_length = local.minimum_password_length
}

resource "null_resource" "users" {
  count = var.pgp_key_path == "" || var.account_email == "" ? 0 : length(keys(var.users))

  triggers = {
    encrypted_password = aws_iam_user_login_profile.user[count.index].encrypted_password
  }

  provisioner "local-exec" {
    # $ alias admin_email user_email user_name encrypted_password
    command = "${path.module}/send-email.sh '${local.account_alias}' '${var.account_email}' '${element(keys(var.users), count.index)}' '${aws_iam_user.user[count.index].name}' '${aws_iam_user_login_profile.user[count.index].encrypted_password}'"
  }
}

# TODO - ssh https://www.terraform.io/docs/providers/aws/r/iam_user_ssh_key.html - pull form gh
