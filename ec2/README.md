# EC2
Auto-scalling cluster of EC2

## Features
- Auto-scaling across defined subnets
- `authorized_keys` generated from users in an IAM group
- CloudWatch logging enabled

## Setup
### Module
```hcl-terraform
module "ec2" {
  source            = "git@github.com:tesera/terraform-modules//ec2"
  name              = "${local.name}-usecase"
  vpc_id            = "${module.vpc.id}"
  subnet_ids        = "${module.vpc.private_subnet_ids}"
  key_name          = "${aws_key_pair.root_public_key.key_name}"
  iam_user_groups   = "Developers"
  iam_sudo_groups   = "Admin"
  image_id          = "${local.image_id}"
  userdata          = "${data.template_file.main-userdata.rendered}"
}
```

### Create custom userdata
```hcl-terraform
data "template_file" "main-userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    REGION          = "${local.aws_region}"
    IAM_USER_GROUPS = "${var.iam_user_groups}"
    IAM_SUDO_GROUPS = "${var.iam_sudo_groups}"
  }
}
```

### Add custom policy
```hcl-terraform
resource "aws_iam_policy" "main-usecase" {
  name        = "${var.name}-usecase-policy"
  path        = "/"
  description = "${var.name}-usecase Policy"

  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll"
      ],
      "Resource": ["${aws_ecs_cluster.main.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-usecase" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "${aws_iam_policy.main-ecs.arn}"
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
- **subnet_ids:** array of public subnet ids
- **key_name:** name of root ssh key
- **iam_user_groups:** name of iam group that should have ssh access, comma separated list
- **iam_sudo_groups:** name of iam group that should have ssh sudo access, comma separated list
- **image_id:** override the base image, must be CentOS based (ie has yum, rpm, docker) [Default: AWS ECS-Optimized]
- **instance_type:** override the instance type [Default: t2.micro]
- **bastion_security_group_id:** bastion security group id [Default: none]
- **userdata:** path to 
- **min_size:** auto-scalling - min instance count [Default: 1]
- **max_size:** auto-scalling - max instance count [Default: 1]
- **desired_capacity:** auto-scalling - desired instance count [Default: 1]

## Output
- **security_group_id:** security group applied, add to ingress on private instance security group
- **iam_role_name:** IAM role name to allow extending of the role
- **billing_suggestion:** comments to improve billing cost


## TODO
- [ ] test CloudWatch Logging
- [ ] OS hardening
  - CIS
  - ClamAV
