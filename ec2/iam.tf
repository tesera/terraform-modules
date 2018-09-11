resource "aws_iam_role" "main" {
  name               = "${var.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


//resource "aws_iam_policy" "main-user-pam" {
//  name        = "${var.name}-user-pam-policy"
//  path        = "/"
//  description = "${var.name} User PAM Policy"
//
//  policy      = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Action": "sts:AssumeRole",
//      "Resource": "arn:aws:iam::${local.account_id}:role/${var.name}-pam-role"
//    }
//  ]
//}
//EOF
//}

//resource "aws_iam_group_policy_attachment" "main-user-pam" {
//  # may run into issues if this group is in another account
//  group      = "${var.iam_user_groups}"
//  policy_arn = "${aws_iam_policy.main-user-pam.arn}"
//}

# Will be assumed via PAM, but has no access to anything
//resource "aws_iam_role" "main-pam" {
//  name               = "${var.name}-pam-assume-role"
//
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "Service": [
//          "ec2.amazonaws.com"
//        ]
//      },
//      "Action": "sts:AssumeRole",
//      "Condition": {
//        "Bool": {
//          "aws:MultiFactorAuthPresent": "true"
//        }
//      }
//    }
//  ]
//}
//EOF
//}



resource "aws_iam_policy" "main-iam" {
  name        = "${var.name}-iam-policy"
  path        = "/"
  description = "${var.name} SSH IAM Policy"

  policy      = <<EOF
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
  role       = "${aws_iam_role.main.name}"
  policy_arn = "${aws_iam_policy.main-iam.arn}"
}

resource "aws_iam_policy" "main-logs" {
  name        = "${var.name}-logs-policy"
  path        = "/"
  description = "${var.name} Logs Policy"

  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-logs" {
  role       = "${aws_iam_role.main.name}"
  policy_arn = "${aws_iam_policy.main-logs.arn}"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.name}-instance-profile"
  role = "${aws_iam_role.main.name}"
}