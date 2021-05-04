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

output "master_account_id" {
  value = var.create_master == true ? aws_organizations_account.master[0].id : null
}

output "master_account_email" {
  value = var.create_master == true ? aws_organizations_account.master[0].email : null
}

