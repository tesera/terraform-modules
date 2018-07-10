output "id" {
  value = "${aws_vpc.main.id}"
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_nat_ips" {
  value = ["${aws_nat_gateway.public.*.public_ip}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_route_table_ids" {
  value = ["${aws_route_table.private.*.id}"]
}

# Used to add additional rules
output "network_acl_id" {
  value = "${aws_network_acl.main.id}"
}
