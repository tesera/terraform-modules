output "id" {
  value = "${aws_vpc.main.id}"
}

output "public_subnet_ids" {
  value = ["${module.public_a.id}","${module.public_b.id}"]
}

output "public_nat_ips" {
  value = ["${module.public_a.ip}","${module.public_b.ip}"]
}

output "private_subnet_ids" {
  value = ["${module.private_a.id}","${module.private_b.id}"]
}

# Used to add additional rules
output "network_acl_id" {
  value = "${aws_network_acl.main.id}"
}
