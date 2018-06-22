output "id" {
  value = "${aws_subnet.main.id}"
}

output "route_table_id" {
  value = "${aws_route_table.main.id}"
}
