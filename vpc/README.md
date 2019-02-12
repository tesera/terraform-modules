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
  source = "git@github.com:tesera/terraform-modules//vpc?ref=v0.1.0"
  name   = "${env}-myapp"
}
```

### Add Gateway Endpoints
```hcl-terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${module.vpc.id}"
  service_name      = "com.amazonaws.${local.workspace["region"]}.s3"
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
  service_name    = "com.amazonaws.${local.workspace["region"]}.dynamodb"
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

### Output config information to SSM Paramstore for use from Serverless, Lambda or other components
```
resource "aws_ssm_parameter" "vpc_sg" {
  name        = "/infrastructure/vpc/sg"
  description = "VPC security group"
  type        = "SecureString"
  value       = "${aws_security_group.lambda.id}"
}

resource "aws_ssm_parameter" "vpc_private_subnets" {
  name        = "/infrastructure/vpc/private_subnets"
  description = "VPC private subnets "
  type        = "SecureString"
  value       = "${join(",", module.vpc.private_subnet_ids)}"
}
```

## Input
Name | Description | Type | Default | Required
-----|-------------|------|---------|----------
name | Application Name | string | `` | No
cidr_block | Custom CIDR block, must end with `.0.0/16` | string | `10.0.0.0/16` | No
az_count | Number on AZs to initialize. Note: RDS/EKS requires min of 2. See [Map](https://aws.amazon.com/about-aws/global-infrastructure/) for AZ count for each region. | string | `2` | No
nat_type | Type of NAT to use `gateway`, `instance` or `none`. See [Comparison](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html). | string | `gateway` | No

### Input for EC2 instance
Name | Description | Type | Default | Required
-----|-------------|------|---------|----------
key_name                  | name of root ssh key, should be used for debug only | string | `` | No
bastion_security_group_id | bastion security group id | string | `` | No
iam_user_groups           | name of iam group that should have ssh access, comma separated list | string | `` | No
iam_sudo_groups           | name of iam group that should have ssh sudo access, comma separated list | string | `` | No
instance_type             | override the instance type | string | `t3.micro` | No

## Output
- **id:** vpc id
- **public_ips:** array of ips attached to NATs
- **public_subnet_ids:** array of public subnet ids
- **private_subnet_ids:** array of private subnet ids
- **private_route_table_ids:** array of private route tables for aws_vpc_endpoints
- **network_acl_id:** ACL id so additional rules can be added


## Configurations

Name       | `development` | `production`
-----------|---------------|------------
`az_count` | 2             | \>=2
`nat_type` | `instance`    | `gateway`

## Known Issues:
- Unable to increase `az_count` when using a NAT instance

## Related
- https://github.com/terraform-aws-modules/terraform-aws-vpc

## TODO

