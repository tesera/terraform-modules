output "public_ip" {
  value = "${aws_eip.main.public_ip}"
}

output "iam_role_name" {
  value = "${aws_iam_role.main.name}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "billing_suggestion" {
  value = "Reserved Instances: ${var.instance_type} x ${local.desired_capacity}"
}
