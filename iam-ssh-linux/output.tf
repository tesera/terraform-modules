output "iam_role_name" {
  value = aws_iam_role.iam_ssh.name
}

output "security_group_id" {
  value = aws_security_group.iam_ssh.id
}


