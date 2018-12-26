# Elastic Kubernetes Service (EKS)
Auto-scaling cluster of EC2 for EKS

** NOT READY FOR PRIME TIME **

## Features
- Auto-scaling across all private subnets
- `authorized_keys` generated from users in an IAM group
- CloudWatch logging enabled

## Setup
`brew insttall kubectrl`
https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
`$ aws --version` must be greater than 1.16

## Restriction/Requirements
- Only certain regions supported (us-east-1, us-west-2, eu-west-1)
- Must be in at least 2 AZ
- VPC CIDR must adhere to https://tools.ietf.org/html/rfc1918 - 10.0.0.0 - 10.255.255.255 (10/8 prefix), 172.16.0.0 - 172.31.255.255  (172.16/12 prefix), 192.168.0.0 - 192.168.255.255 (192.168/16 prefix)

### Module
```hcl-terraform
module "vpc" {
  source       = "../../vpc"
  name         = "${local.name}"
  az_count     = "2"
  cidr_block   = "10.5.0.0/16"
  nat_type     = "gateway"
  default_tags = "${map(
    "Environment", "${var.environment}",
    "kubernetes.io/cluster/${local.name}-eks", "shared"    # Important name matches cluster_name
  )}"
}

module "eks" {
  source            = "git@github.com:tesera/terraform-modules//eks"
  name              = "${local.name}"
  vpc_id            = "${module.vpc.id}"
  private_subnet_ids = "${module.vpc.private_subnet_ids}"
  iam_user_groups   = "Developers"
  iam_sudo_groups   = "Admin"
}

output "cluster_name" {
  value = "${module.eks.name}"
}
```

## Input
- **vpc_id:** vpc id
- **private_subnet_ids:** array of private subnet ids
- **key_name:** name of root ssh key [Default: none]
- **iam_user_groups:** name of iam group that should have ssh access, comma separated list
- **iam_sudo_groups:** name of iam group that should have ssh sudo access, comma separated list
- **image_id:** override the base image, must be CentOS based (ie has yum, rpm, docker) [Default: AWS EKS-Optimized]
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

## Issues
Because EKS is still new, sufficient capacity can be an issue. If you run into:
```bash
Cannot create cluster 'example-cluster' because us-east-1d, the targeted availability zone, does not currently have sufficient capacity to support the cluster. Retry and choose from these availability zones: us-east-1a, us-east-1b, us-east-1c
```
Removing that az from the private_subnet_ids will be required. Checkout the [`slice`](https://www.terraform.io/docs/configuration/interpolation.html#slice-list-from-to-) interpolation.

## References
- [Getting Started with AWS EKS](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)

## TODO
- multi-account: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/101
