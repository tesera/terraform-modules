output "postgres_endpoint" {
  value = "${aws_db_instance.master.endpoint}"
}

output "password" {
  value = "${aws_db_instance.master.password}"
}

output "username" {
  value = "${aws_db_instance.master.username}"
}

output "security_group_id" {
  value = "${var.vpc_security_group_ids}"
}
