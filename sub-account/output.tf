output "id" {
  value = local.account_id
}

output "roles" {
  value = [aws_iam_role.administrator.arn, aws_iam_role.developer.arn]
}

