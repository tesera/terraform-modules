# rds proxy
Allow direct connection to private subnet rds instances. This should only be used if 3rd party cannot use ssh keys, ie FMECloud.

## Features
- static ip address
- Auto-scaling across all public subnets
- `authorized_keys` generated from users in an IAM group
- CloudWatch logging enabled

## Setup
### Module
```hcl-terraform
module "proxy" {
  source            = "git@github.com:tesera/terraform-modules//proxy"
  name              = "${local.name}"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.vpc.public_subnet_ids}"
  iam_user_groups   = "Developers"
  iam_sudo_groups   = "Admin"
  
  rds_endpoint      = "app-master-postgres.********.ca-central-1.rds.amazonaws.com"
}

resource "aws_security_group_rule" "proxy" {
  security_group_id        = "${module.proxy.security_group_id}"
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
}

```

### Add a security group rule that grants permission to external server to access the db instance
```hcl-terraform
resource "aws_security_group_rule" "proxy" {
  security_group_id        = "${module.rds.security_group_id}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${module.proxy.security_group_id}"
}
```

## Input
- **vpc_id:** vpc id
- **public_subnet_ids:** array of public subnet ids
- **key_name:** name of root ssh key [Default: none]
- **iam_user_groups:** name of iam group that should have ssh access, comma separated list
- **iam_sudo_groups:** name of iam group that should have ssh sudo access, comma separated list
- **image_id:** override the base image, must be CentOS based (ie has yum and rpm) [Default: AWS Linux]
- **instance_type:** override the instance type [Default: t2.micro]
- **bastion_security_group_id:** bastion security group id [Default: none]
- **proxy_name:** name of the proxy [Default: proxy]
- **proxy_endpoint:** RDS domain endpoint
- **proxy_port:** port to proxy [Default: 443]

## Output
- **public_ip:** public ip
- **security_group_id:** security group applied, add to ingress on private instance security group
- **iam_role_name:** IAM role name to allow extending of the role
- **billing_suggestion:** comments to improve billing cost



## TODO
- [ ] only able to proxy streams
- [ ] Allow multiple proxies
- [ ] Connect proxy logs to cloudwatch
