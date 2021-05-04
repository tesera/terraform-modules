output "id" {
  value = local.account_id
}

output "sub_accounts" {
  value = zipmap(var.sub_accounts, values(aws_organizations_account.environments)[*].id)
}

output "sub_account_ids" {
  value = values(aws_organizations_account.environments)[*].id
}

output "sub_account_emails" {
  value = values(aws_organizations_account.environments)[*].email
}

