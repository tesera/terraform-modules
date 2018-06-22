output "id" {
  value = "${aws_subnet.main.id}"
}

output "ip" {
  value = "${aws_eip.nat.public_ip}"
}

output "gateway_id" {
  value = "${aws_nat_gateway.main.id}"
}
