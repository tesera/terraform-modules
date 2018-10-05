# ECS
Auto-scaling cluster of EC2 for ECS

## Features
- Auto-scaling across all private subnets
- `authorized_keys` generated from users in an IAM group
- CloudWatch logging enabled

## Setup
### Module
```hcl-terraform
module "ecs" {
  source            = "git@github.com:tesera/terraform-modules//ecs"
  name              = "${local.name}"
  vpc_id            = "${module.vpc.id}"
  private_subnet_ids = "${module.vpc.private_subnet_ids}"
  iam_user_groups   = "Developers"
  iam_sudo_groups   = "Admin"
}
```

## Input
- **vpc_id:** vpc id
- **private_subnet_ids:** array of private subnet ids
- **key_name:** name of root ssh key [Default: none]
- **iam_user_groups:** name of iam group that should have ssh access, comma separated list
- **iam_sudo_groups:** name of iam group that should have ssh sudo access, comma separated list
- **image_id:** override the base image, must be CentOS based (ie has yum, rpm, docker) [Default: AWS ECS-Optimized]
- **instance_type:** override the instance type [Default: t2.micro]
- **bastion_security_group_id:** bastion security group id [Default: none]
- **min_size:** auto-scaling - min instance count [Default: 2]
- **max_size:** auto-scaling - max instance count [Default: 2]
- **desired_capacity:** auto-scaling - desired instance count [Default: 2]

## Output
- **name:** ecs cluster name
- **security_group_id:** security group applied, add to ingress on private instance security group
- **iam_role_name:** IAM role name to allow extending of the role
- **billing_suggestion:** comments to improve billing cost


## TODO
- [ ] test CloudWatch Logging
- [ ] OS hardening
  - CIS
  - ClamAV
