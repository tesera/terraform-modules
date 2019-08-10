output "id" {
  value = local.account_id
}

output "sub_account_emails" {
  value = aws_organizations_account.main.*.email
}

