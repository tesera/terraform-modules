output "public_ip" {
  value = "${aws_eip.main.public_ip}"
}

output "billing_suggestion" {
  value = "Reserved Instances: ${var.instance_type} x ${local.desired_capacity}"
}
