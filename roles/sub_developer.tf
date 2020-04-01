resource "aws_iam_role" "developer" {
  count = var.type != "master" ? 1 : 0
  name  = "developer"

  assume_role_policy = <<EOF
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
EOF

}

/*
"Condition": {
  "Bool": {
    "aws:MultiFactorAuthPresent": "true"
  }
}
*/

resource "aws_iam_role_policy_attachment" "developer" {
  count = var.type != "master" ? 1 : 0
  role = aws_iam_role.developer[0].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

