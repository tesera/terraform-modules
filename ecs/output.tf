output "name" {
  value = "${aws_ecs_cluster.main.name}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "billing_suggestion" {
  value = "Reserved Instances: ${var.instance_type} x ${local.desired_capacity}"
}
