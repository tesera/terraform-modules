output "arns" {
  value = [aws_iam_role.ssh.*.arn]
}

