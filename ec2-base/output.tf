output "iam_role_name" {
  value = aws_iam_role.main.name
}

output "iam_role_arn" {
  value = aws_iam_role.main.arn
}

output "security_group_id" {
  value = aws_security_group.main.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.main.name
}

output "billing_suggestion" {
  value = "Reserved Instances: ${var.instance_type} x ${local.desired_capacity} (${local.region})"
}

