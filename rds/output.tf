output "endpoint" {
  value = "${aws_db_instance.main.endpoint}"
}

output "username" {
  value = "${aws_db_instance.main.username}"
}

output "password" {
  value = "${aws_db_instance.main.password}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "billing_suggestion" {
  value = "Reserved Instances: ${var.instance_class} x ${var.replica_count+1}"
}