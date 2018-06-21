







## Add-ons

### S3 endpoints
```hcl-terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${aws_vpc.main.id}"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = ["${aws_route_table.private.id}"]
}
```


## TODO
- [ ] IPv6 - https://www.terraform.io/docs/providers/aws/r/vpc.html#assign_generated_ipv6_cidr_block
