# VPC
Creates a VPC over two AZ w/ NAT.

<div align="center">
  <a href="http://gordonfoundation.ca"><img src="https://raw.githubusercontent.com/tesera/terraform-modules/master/vpc/diagram.png?token=&sanitize=true" alt="Module Diagram" width="200"></a>
</div>

## Features
- 1 region
- 2 availability zones (AZ)
- 1 public, 1 private subnet per AZ
- 1 NAT per public subnet
- ACL - Allow http, https, dns, icmp, ssh, ephemeral ports

## Setup

### Module

```hcl-terraform
module "vpc" {
  source = "git@github.com:tesera/terraform-modules//vpc"
  name   = "${env}-myapp"
}
```

### Add Gateway Endpoints
```hcl-terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${module.vpc.id}"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = ["${module.vpc.private_route_table_ids}"]
  policy            = <<POLICY
{
  "Statement": [
      {
          "Action": "*",
          "Effect": "Allow",
          "Resource": "*",
          "Principal": "*"
      }
  ]
}
POLICY
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = "${module.vpc.id}"
  service_name    = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = ["${module.vpc.private_route_table_ids}"]
  policy          = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY
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
- **cidr_block:** Custom CIDR block, must end with `.0.0/16` [Default: `10.0.0.0/16`]
- **az_count:** Number on AZ to initialize [Default: 2, Max: 15]. Note: RDS requires min of 2. See [Map](https://aws.amazon.com/about-aws/global-infrastructure/) for AZ count for each region.
- **nat_type:** Type of NAT to use `gateway` or `instance` [Default: `gateway`]. See [Comparison](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html)

### Input for NAT instance
- **key_name:** name of root ssh key [Default: none]
- **iam_user_groups:** name of iam group that should have ssh access, comma separated list [Default: none]
- **iam_sudo_groups:** name of iam group that should have ssh sudo access, comma separated list [Default: none]
- **instance_type:** override the instance type [Default: t2.micro]
- **bastion_security_group_id:** bastion security group id [Default: none]

## Output
- **id:** vpc id
- **public_ips:** array of ips attached to NATs
- **public_subnet_ids:** array of public subnet ids
- **private_subnet_ids:** array of private subnet ids
- **private_route_table_ids:** array of private route tables for aws_vpc_endpoints
- **network_acl_id:** ACL id so additional rules can be added

## Known Issues:
`Error deleting Lambda Function: InvalidParameterValueException: Lambda was unable to delete * because it is a replicated function.` See https://github.com/terraform-providers/terraform-provider-aws/issues/1721 for ongoing support.

## TODO
- [ ] Add IPv6 - https://www.terraform.io/docs/providers/aws/r/vpc.html#assign_generated_ipv6_cidr_block
- [ ] Option to modify CIDR if VPC peering ever happen
- [ ] Main route table created without name - make public? or name?
- [ ] "" same for Network ACLs

