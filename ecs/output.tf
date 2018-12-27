output "name" {
  value = "${aws_ecs_cluster.main.name}"
}

output "id" {
  value = "${aws_ecs_cluster.main.id}"
}

# EC2 Output
output "iam_role_name" {
  value = "${module.ec2.iam_role_name}"
}

output "iam_role_arn" {
  value = "${module.ec2.iam_role_arn}"
}

output "security_group_id" {
  value = "${module.ec2.security_group_id}"
}

output "billing_suggestion" {
  value = "${module.ec2.billing_suggestion}"
}
