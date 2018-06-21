# VPC
Creates a VPC over two AZ w/ NAT.

<div align="center">
  <a href="http://gordonfoundation.ca"><img src="https://raw.githubusercontent.com/tesera/terraform-modules/master/vpc/diagram.png?token=&sanitize=true" alt="Module Diagram" width="200"></a>
</div>

## Setup

### Module

```hcl-terraform
module "vpc" {
  source = "github.com/tesera/terraform-modules/vpc"
  name = "${env}-myapp"
}
```

### Add S3 Endpoints
```hcl-terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${module.vpc.id}"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = ${module.vpc.private_subnet_ids}
}
```

### Extra ACL Rules
```hcl-terraform
# Postgres
resource "aws_network_acl_rule" "ingress_postgres" {
  network_acl_id = "${module.vpc.network_acl_id}"
  rule_number    = 5432
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "egress_postgres" {
  network_acl_id = "${module.vpc.network_acl_id}"
  rule_number    = 5432
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5432
  to_port        = 5432
}
```

## Input
- **name:** application name

## Output

- **id:** vpc id
- **public_nat_ips:** array of ips attached to NATs
- **public_subnet_ids:** array of public subnet ids
- **private_subnet_ids:** array of private subnet ids
- **network_acl_id:** ACL id so additional rules can be added


## TODO
- [ ] Add IPv6 - https://www.terraform.io/docs/providers/aws/r/vpc.html#assign_generated_ipv6_cidr_block
