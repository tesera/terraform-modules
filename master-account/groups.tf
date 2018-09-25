# TODO tf v0.12 - https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each
# ${sub_account}-${role}-group

#flatten(split(",",format("%.24s", var.sub_accounts[count.index], "-", join(format("%.24s", var.sub_accounts[count.index], "-"), local.groups))))

resource "aws_iam_group" "groups" {
  count = "${length(keys(local.groups))}"
  name  = "${local.groups[count.index]}"
}

# Update after v0.12.0
resource "aws_iam_policy" "groups" {
  count       = "${length(keys(local.groups))}"
  name        = "${local.groups[count.index]}-policy"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      },
      "Resource": [
        "arn:aws:iam::${aws_organizations_account.main.*.id[index(aws_organizations_account.main.*.id, element(split("-",local.groups[count.index]),0))]}]:role/${element(split("-",local.groups[count.index]),1)}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "groups" {
  count      = "${length(keys(local.groups))}"
  group      = "${aws_iam_group.groups.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.groups.*.arn[count.index]}"
}

# Billing - https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-permissions-ref.html
resource "aws_iam_group" "billing" {
  name = "Billing"
}

resource "aws_iam_policy" "billing" {
  name        = "billing-policy"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "aws-portal:*Billing"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "billing" {
  count      = "${length(local.groups)}"
  group      = "${aws_iam_group.billing.name}"
  policy_arn = "${aws_iam_policy.billing.arn}"
}
