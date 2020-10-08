output "list" {
  value = concat(
    [aws_iam_group.admin.name, aws_iam_group.billing.name],
    aws_iam_group.groups.*.name,
    [aws_iam_group.user.name],
  )
}

//output "users" {
//  value = "${aws_iam_user.users.*.name}"
//}
//
//output "passwords" {
//  value = "${aws_iam_user_login_profile.users.*.encrypted_password}"
//}
//data "null_data_source" "users" {
//  count = "${length(aws_iam_user.users.*.name)}"
//  inputs = "${aws_iam_user.users.*.name[count.index]}:${aws_iam_user_login_profile.users.*.encrypted_password[count.index]}"
//}
//
//output "sub_account_emails" {
//  value = "${aws_organizations_account.main.*.email}"
//}
