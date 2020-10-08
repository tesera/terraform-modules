resource "aws_iam_role" "iam_ssh" {
  name = "${local.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_ssh" {
  name = "${local.name}-profile"
  role = aws_iam_role.iam_ssh.name
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.iam_ssh.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.iam_ssh.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "iam_ssh" {
  role       = aws_iam_role.iam_ssh.name
  policy_arn = aws_iam_policy.ssh_iam.arn
}

resource "aws_iam_policy" "ssh_iam" {
  name        = "${local.name}-iam-policy"
  path        = "/"
  description = "${local.name} SSH IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${local.assume_role_arn}"
      ]
    }, {
      "Effect": "Allow",
      "Action": "ec2:DescribeTags",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "main-iam" {
  role       = aws_iam_role.iam_ssh.name
  policy_arn = aws_iam_policy.ssh_iam.arn
}

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
