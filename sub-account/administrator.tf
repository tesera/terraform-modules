resource "aws_iam_role" "administrator" {
  name = "admin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${var.master_account_id}:root"
      },
      "Effect": "Allow",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "administrator" {
  role       = "${aws_iam_role.administrator.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
