# bastion
Allow ssh to private subnet services.

## Features
- static ip address
- Auto-scaling across all public subnets
- `authorized_keys` generated from users in an IAM group
- `fail2ban` enabled
- CloudWatch logging enabled

## Setup
### Module
```hcl-terraform
module "bastion" {
  source            = "github.com/tesera/terraform-modules/bastion"
  name              = "${local.name}"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.vpc.public_subnet_ids}"
  key_name          = "${local.key_name}"
  iam_ssh_group     = "Admin"
}
```

### Create global SSH key
```hcl-terraform
resource "aws_key_pair" "root_public_key" {
  key_name   = "root_public_key"
  public_key = "ssh-rsa ...== COMMENT"
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
- **public_subnet_ids:** array of public subnet ids
- **key_name:** name of root ssh key
- **iam_ssh_group:** name of iam group that should have ssh access
- **image_id:** override the base image, must be CentOS based (ie has yum and rpm) [Default: AWS Linux]
- **instance_type:** override the instance type [Default: t2.micro]

## Output
- **public_ip:** public ip
- **billing_suggestion:** comments to improve billing cost

## SSH
Sample Bastion Host Proxy (`~/.ssh/ssh_config.d/${name}-${env}`)
```bash
### Company Name (cn) ###

# ssh -N cn-proxy-test
Host cn-proxy-test
  HostName #.#.#.#
  IdentityFile ~/.ssh/id_ed25512
  User USERNAME
  ControlPath /tmp/ssh_sn-proxy-demo
  LocalForward 3307 mysql-test.*****.us-east-1.rds.amazonaws.com:3306
  LocalForward 6378 redis-test.*****.0001.use1.cache.amazonaws.com:6379

Host cn-bastion-test
  HostName #.#.#.#
  IdentityFile ~/.ssh/id_ed25512
  User USERNAME
  ControlPath /tmp/ssh_sn-bastion-test

Host cn-test-*
  ProxyCommand ssh -W %h:%p sn-bastion-demo
  IdentityFile ~/.ssh/id_ed25512
  User USERNAME
  
# Add hosts behind bastion here
Host cn-test-web-1
  HostName 10.0.0.1
```

## TODO
- [ ] test CloudWatch Logging
- [ ] fail2ban alerts
- [ ] MFA - google authenticator
- [ ] OS hardening
  - CIS
  - ClamAV
