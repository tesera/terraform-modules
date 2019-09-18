output "id" {
  value = aws_vpc.main.id
}

# For bastion, proxy
output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

# For ECS, RDS, etc
output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

# For VPC endpoints
output "private_route_table_ids" {
  value = concat(
    aws_route_table.private-gateway.*.id,
    aws_route_table.private-instance.*.id
  )
}

# For whitelisting on 3rd party services
output "public_ips" {
  value = aws_eip.nat.*.public_ip
}

# Used to add additional rules
output "network_acl_id" {
  value = aws_network_acl.public.id
}

