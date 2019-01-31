# Bastion
Allow ssh to private subnet services.

## Features
- static ip address
- Auto-scaling across all public subnets
- `authorized_keys` generated from users in an IAM group
- `fail2ban` enabled
- CloudWatch logging enabled
- CloudWatch agent for collecting additional metrics
- Inspector agent for allowing running of security assessments in Amazon Inspector
- SSM Agent for allowing shell access from Session AWS Systems Manager

## Test
```bash
ssh -i ~/.ssh/id_rsa username@{bastion_ip}
```

## Setup

### Prerequisites
Before using this terraform module, the "bastion" and "ec2" AMIs need to be created in all required regions with Packer - https://github.com/tesera/terraform-modules/blob/master/packer/README.md. 

### Module
```hcl-terraform
module "bastion" {
  source            = "git@github.com:tesera/terraform-modules//bastion?ref=v0.1.3"
  name              = "${local.workspace["name"]}"
  instance_type     = "${local.workspace["bastion_instance_type"]}"
  vpc_id            = "${module.vpc.id}"
  network_acl_id    = "${module.vpc.network_acl_id}"
  public_subnet_ids = "${module.vpc.public_subnet_ids}"
  iam_user_groups   = "${local.workspace["bastion_user_group"]}"
  iam_sudo_groups   = "${local.workspace["bastion_sudo_group"]}"
  assume_role_arn   = "${element(matchkeys(data.terraform_remote_state.master.bastion_role_arns, keys(data.terraform_remote_state.master.sub_accounts), list(terraform.workspace)),0)}"
}
```

### Create user group
```hcl-terraform
resource "aws_iam_group" "developers" {
  name = "developers"
}
```

## Input
- **vpc_id:** vpc id
- **network_acl_id:** VPC ACL id to allow port 22 (ingress/egress)
- **public_subnet_ids:** array of public subnet ids
- **key_name:** name of root ssh key
- **iam_user_groups:** name of iam group that should have ssh access, comma separated list
- **iam_sudo_groups:** name of iam group that should have ssh sudo access, comma separated list
- **image_id:** override the base image, must be CentOS based (ie has yum and rpm) [Default: AWS Linux]
- **instance_type:** override the instance type [Default: t3.micro]

## Output
- **public_ip:** public ip
- **security_group_id:** security group applied, add to ingress on private instance security group
- **iam_role_name:** IAM role name to allow extending of the role
- **billing_suggestion:** comments to improve billing cost

## SSH
Sample Bastion Host Proxy (`~/.ssh/ssh_config.d/${name}-${env}`)
```bash
### Company Name (cn) | Project (test) ###
# Replace: USERNAME, BASTIONIP, PRIVATEIP

# ssh -N cn-proxy-test
Host cn-proxy-test
  HostName **BASTIONIP**
  IdentityFile ~/.ssh/id_rsa
  User **USERNAME**
  ControlPath /tmp/ssh_cn-proxy-test
  LocalForward 3307 mysql-test.*****.us-east-1.rds.amazonaws.com:3306
  LocalForward 5432 postgres-test.*****.us-east-1.rds.amazonaws.com:5432
  LocalForward 6378 redis-test.*****.0001.use1.cache.amazonaws.com:6379

Host cn-bastion-test
  HostName **BASTIONIP**
  IdentityFile ~/.ssh/id_rsa
  User USERNAME
  ControlPath /tmp/ssh_cn-bastion-test

Host cn-test-*
  ProxyCommand ssh -W %h:%p sn-bastion-demo
  IdentityFile ~/.ssh/id_rsa
  User **USERNAME**
  
# Add hosts behind bastion here
Host cn-test-ecs
  HostName **PRIVATEIP**
```

## References
- [widdix/aws-ec2-ssh](https://github.com/widdix/aws-ec2-ssh/blob/master/aws-ec2-ssh.conf)
