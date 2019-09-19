# This allow a bastion in a sub account to read the SSH key for users in a group
resource "aws_iam_role" "ssh" {
  count              = var.assume_role_arn == "" ? 1 : 0
  name               = "${local.name}-ssh-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ssh" {
  count      = var.assume_role_arn == "" ? 1 : 0
  role       = aws_iam_role.ssh[0].name
  policy_arn = aws_iam_policy.ssh[0].arn
}

resource "aws_iam_policy" "ssh" {
  count = var.assume_role_arn == "" ? 1 : 0
  name  = "${local.name}-ssh-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListUsers",
        "iam:GetGroup"
      ],
      "Resource": "*"
    }, {
      "Effect": "Allow",
      "Action": [
        "iam:GetSSHPublicKey",
        "iam:ListSSHPublicKeys"
      ],
      "Resource": [
        "arn:aws:iam::${local.account_id}:user/*"
      ]
    }
  ]
}
POLICY
}
