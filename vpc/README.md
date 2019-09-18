# VPC
Creates a VPC over two AZ w/ NAT Instance or NAT Gateway in each AZ.

<div align="center">
  <a href="http://gordonfoundation.ca"><img src="https://raw.githubusercontent.com/tesera/terraform-modules/master/vpc/diagram.png?token=&sanitize=true" alt="Module Diagram" width="200"></a>
</div>

## Features
- 1 region
- 2+ availability zones (AZ)
- 1 public, 1 private subnet per AZ
- 1 NAT per public subnet
- ACL - Allow http, https, dns, ephemeral ports, easy to extend

## Setup

### Module

```hcl-terraform
module "vpc" {
  source = "./terraform-modules/vpc"
  name           = local.workspace["name"]
  az_count       = local.workspace["az_count"]
  cidr_block     = local.workspace["cidr_block"]
  nat_type       = local.workspace["nat_type"]
  ami_account_id = data.terraform_remote_state.master.outputs.account_id
}
```

## Outputs
```hcl-terraform
output "nat_ips" {
  value = module.vpc.public_ips
}

output "nat_billing_suggestion" {
  value = module.vpc.billing_suggestion
}

# Output config information to SSM Paramstore for use from Serverless, Lambda or other components
resource "aws_ssm_parameter" "vpc_id" {
  name        = "/infrastructure/vpc/id"
  description = "VPC ID for ${var.name}-${var.environment}"
  type        = "SecureString"
  value       = module.vpc.id
}

resource "aws_ssm_parameter" "vpc_public_subnets" {
  name        = "/infrastructure/vpc/public_subnets"
  description = "VPC public subnets for ${var.name}-${var.environment}"
  type        = "SecureString"
  value       = join(",", module.vpc.public_subnet_ids)
}

resource "aws_ssm_parameter" "vpc_private_subnets" {
  name        = "/infrastructure/vpc/private_subnets"
  description = "VPC private subnets for ${var.name}-${var.environment}"
  type        = "SecureString"
  value       = join(",", module.vpc.private_subnet_ids)
}

```

### Add Gateway Endpoints
```hcl-terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.id
  service_name      = "com.amazonaws.${local.workspace["region"]}.s3"
  route_table_ids   = module.vpc.private_route_table_ids  
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = module.vpc.id
  service_name    = "com.amazonaws.${local.workspace["region"]}.dynamodb"
  route_table_ids = module.vpc.private_route_table_ids
}

```

### Extra ACL Rules
```hcl-terraform
# Postgres
resource "aws_network_acl_rule" "ingress_postgres" {
  network_acl_id = module.vpc.network_acl_id
  rule_number    = 5432
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "::/0"
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "egress_postgres" {
  network_acl_id = module.vpc.network_acl_id
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
Name           | Type        | Default       | Required | Description
---------------|-------------|---------------|----------|-------------
name           | string      | ``            | No       | Application Name
default_tags   | map(string) | `{}`          | No       | Tag to apply to all resources
cidr_block     | string      | `10.0.0.0/16` | No       | Custom CIDR block, must end with `.0.0/16`
az_count       | string      | `2`           | No       | Number on AZs to initialize. Note: RDS/EKS requires min of 2. See [Map](https://aws.amazon.com/about-aws/global-infrastructure/) for AZ count for each region.
nat_type       | string      | `none`        | No       | Type of NAT to use `gateway`, `instance` or `none`. See [Comparison](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html).
instance_type  | string      | `t3.micro`    | No       | When `nat_type == instance`. override the instance type
ami_account_id | string      | `self`        | No       | When `nat_type == instance`. account id where the AMI resides. See [Packer NAT](https://github.com/tesera/terraform-modules/tree/master/packer/nat).

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

