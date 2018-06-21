# VPC
Creates a VPC over two AZ w/ NAT.

## Setup

### Module

```hcl-terraform
module "vpc" {
  source = "github.com/tesera/terraform-modules/vpc"
  
  name = "${env}-myapp"
  aws_region = "${aws_region}"
}
```

### S3 endpoints
```hcl-terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${module.vpc.id}"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = ${module.vpc.private_subnet_ids}
}
```

## Input
- **name:** application name
- **aws_region:** AWS region

## Output

- **id:** vpc id
- **public_nat_ips:** array of ips attached to NATs
- **public_subnet_ids:** array of public subnet ids
- **private_subnet_ids:** array of private subnet ids
- **network_acl_id:** ACL id so additional rules can be added


## TODO
- [ ] Add IPv6 - https://www.terraform.io/docs/providers/aws/r/vpc.html#assign_generated_ipv6_cidr_block
