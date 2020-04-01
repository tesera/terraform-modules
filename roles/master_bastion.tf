# This allow a bastion in a sub account to read the SSH key for users in a group
resource "aws_iam_role" "bastion" {
  count = var.enable_bastion && var.type == "master" ? length(keys(local.sub_accounts)) : 0
  name  = "${element(keys(local.sub_accounts), count.index)}-ssh-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${var.sub_accounts[element(keys(local.sub_accounts), count.index)]}:root"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bastion" {
  count = var.enable_bastion && var.type == "master" ? length(keys(local.sub_accounts)) : 0
  role = aws_iam_role.bastion.*.name[count.index]
  policy_arn = aws_iam_policy.bastion[0].arn
}

resource "aws_iam_policy" "bastion" {
  count = var.enable_bastion && var.type == "master" ? 1 : 0
  name = "sub-account-ssh-policy"

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
