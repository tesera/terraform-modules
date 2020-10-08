resource "aws_iam_role" "administrator" {
  count = var.type != "master" ? 1 : 0
  name  = "admin"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${var.master_account_id}:root"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY

}

/*
"Condition": {
  "Bool": {
    "aws:MultiFactorAuthPresent": "true"
  }
}
*/

resource "aws_iam_role_policy_attachment" "administrator" {
  count = var.type != "master" ? 1 : 0
  role = aws_iam_role.administrator[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

