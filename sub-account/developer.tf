
resource "aws_iam_role" "developer" {
    name = "${local.name}-developer-role"
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

# TODO lock down to read only
resource "aws_iam_policy" "developer" {
    name        = "${local.name}-developer-policy"
    description = "A test policy"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "developer" {
    role       = "${aws_iam_role.developer.name}"
    policy_arn = "${aws_iam_policy.developer.arn}"
}


