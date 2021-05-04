resource "aws_organizations_organization" "account" {
  count       = var.use_existing_organization == true ? 0 : 1
  feature_set = "ALL"
  enabled_policy_types = [
  "SERVICE_CONTROL_POLICY"]

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "fms.amazonaws.com",
  ]
}

data "aws_organizations_organization" "account" {
  depends_on = [
    aws_organizations_organization.account
  ]
}

resource "aws_organizations_organizational_unit" "environments" {
  name      = var.organizational_unit_name
  parent_id = data.aws_organizations_organization.account.roots.0.id
}

resource "aws_organizations_policy_attachment" "environments" {
  count = var.use_existing_organization == true ? 0 : 1
  depends_on = [
    data.aws_organizations_organization.account
  ]
  policy_id = aws_organizations_policy.environments[0].id
  target_id = aws_organizations_organizational_unit.environments.id
}

resource "aws_organizations_policy" "environments" {
  count       = var.use_existing_organization == true ? 0 : 1
  name        = "org-environments-policy"
  description = "Allows access to every operation"

  content = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }
}
POLICY
}

resource "aws_organizations_account" "master" {
  count                      = var.create_master == true ? 1 : 0
  name                       = "${var.organizational_unit_name}-master"
  email                      = "${local.account_email_local_part}+master@${local.account_email_domain}"
  iam_user_access_to_billing = "DENY"
  parent_id                  = aws_organizations_organizational_unit.environments.id

  lifecycle {
    ignore_changes = [iam_user_access_to_billing, role_name] # https://www.terraform.io/docs/providers/aws/r/organizations_account.html#import
  }

  /*tags = merge(
  local.tags,
  {
    "Name" = "${var.organizational_unit_name}-master"
  }
  )*/
}


// Docs: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create.html
// To set password go to root sign up and enter email
resource "aws_organizations_account" "environments" {
  for_each = var.sub_accounts

  name                       = "${var.organizational_unit_name}-${each.value}"
  email                      = "${local.account_email_local_part}+${each.value}@${local.account_email_domain}"
  iam_user_access_to_billing = "DENY"
  parent_id                  = aws_organizations_organizational_unit.environments.id

  lifecycle {
    ignore_changes = [iam_user_access_to_billing, role_name] # https://www.terraform.io/docs/providers/aws/r/organizations_account.html#import
  }

  /*tags = merge(
  local.tags,
  {
    "Name" = "${var.organizational_unit_name}-${each.value}"
  }
  )*/
}
