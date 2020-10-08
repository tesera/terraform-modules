output "id" {
  value = local.account_id
}

output "sub_accounts" {
  value = zipmap(var.sub_accounts, aws_organizations_account.environment.*.id)
}

output "sub_account_ids" {
  value = aws_organizations_account.environment.*.id
}

output "sub_account_emails" {
  value = aws_organizations_account.environment.*.email
}

