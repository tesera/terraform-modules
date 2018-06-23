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
  value = "${aws_security_group.db.id}"
}
