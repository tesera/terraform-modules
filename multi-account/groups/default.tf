
# https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-as-root
# To grant permissions to members of an IAM group in the master account to access the role (console)
resource "aws_iam_group" "organization" {
  name = "OrganizationAccountAccessGroup"
}
resource "aws_iam_policy" "organization" {
  name   = "OrganizationAccountAccessPolicy"
  policy = data.aws_iam_policy_document.organization.json
}

data "aws_iam_policy_document" "organization" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = split(",", "arn:aws:iam::${join(":role/OrganizationAccountAccessRole,arn:aws:iam::", values(var.sub_accounts))}:role/OrganizationAccountAccessRole")
    condition {
      test     = "Bool"
      values   = true
      variable = "aws:MultiFactorAuthPresent"
    }
  }
}

resource "aws_iam_group_policy_attachment" "organization" {
  group      = aws_iam_group.organization.name
  policy_arn = aws_iam_policy.organization.arn
}
