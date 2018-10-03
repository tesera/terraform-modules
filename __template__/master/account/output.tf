# Used by environments/account
output "account_id" {
  value = "${module.account.id}"
}

output "alias" {
  value = "${module.account.alias}"
}
output "groups" {
  value = "${module.account.groups}"
}
output "sub_account_emails" {
  value = "${module.account.sub_account_emails}"
}
