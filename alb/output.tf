output "id" {
  value = "${aws_lb.main.id}"
}

output "arn" {
  value = "${aws_lb.main.arn}"
}

output "target_group_arn" {
  value = "${aws_lb_target_group.main.arn}"
}

output "endpoint" {
  value = "${aws_lb.main.dns_name}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}
