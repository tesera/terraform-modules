





# Users
resource "aws_iam_user" "users" {
  count = "${length(keys(var.users))}"
  name  = "${element(keys(var.users), count.index)}"
}

resource "aws_iam_user_group_membership" "users" {
  count  = "${length(keys(var.users))}"
  user   = "${element(keys(var.users), count.index)}"

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
  minimum_password_length        = 32
  require_lowercase_characters   = false
  require_uppercase_characters   = false
  require_numbers                = false
  require_symbols                = false
}
