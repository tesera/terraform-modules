output "efs_id" {
  value = "${aws_efs_file_system.main.id}"
}

output "efs_dns_name" {
  value = "${aws_efs_file_system.main.dns_name}"
}
