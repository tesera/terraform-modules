output "name" {
  value = aws_ecs_cluster.main.name
}

output "id" {
  value = aws_ecs_cluster.main.id
}

output "arn" {
  value = aws_ecs_cluster.main.arn
}

# EC2 Output
output "iam_role_name" {
  value = module.ec2.iam_role_name
}

output "iam_role_arn" {
  value = module.ec2.iam_role_arn
}

output "iam_execution_role_name" {
  value = aws_iam_role.task_execution.name
}

output "iam_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "security_group_id" {
  value = module.ec2.security_group_id
}

output "autoscaling_group_name" {
  value = module.ec2.autoscaling_group_name
}

output "billing_suggestion" {
  value = module.ec2.billing_suggestion
}

