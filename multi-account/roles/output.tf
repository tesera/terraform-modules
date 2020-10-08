output "arns" {
  value = flatten([aws_iam_role.administrator.*.arn, aws_iam_role.developer.*.arn, aws_iam_role.bastion.*.arn])
}

output "bastion_arns" {
  value = aws_iam_role.bastion.*.arn
}

output "ecr_arns" {
  value = aws_iam_role.ecr.*.arn
}
