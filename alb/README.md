# ALB
Application Load Balancer for ECS

## Features

## Setup

### Prerequisites
Before using this terraform module, the "ec2" and "ecs" AMIs need to be created in all required regions with Packer - https://github.com/tesera/terraform-modules/blob/master/packer/README.md. 

### Module
```hcl-terraform
# Cert
data "aws_acm_certificate" "main" {
  domain   = "${local.workspace["domain"]}"

  statuses = [
    "ISSUED",
  ]
}

# WAF
module "waf" {
  source        = "git@github.com:tesera/terraform-modules//waf-region-owasp?ref=v0.2.4"
  name          = "${local.workspace["name"]}"
  defaultAction = "ALLOW"
}

# ALB
module "alb" {
  source                 = "git@github.com:tesera/terraform-modules//alb?ref=v0.2.10"
  name                   = "${local.workspace["name"]}"
  vpc_id                 = "${data.terraform_remote_state.vpc.vpc_id}"

  private_subnet_ids     = [
    "${data.terraform_remote_state.vpc.private_subnet_ids}",
  ]

  waf_acl_id             = "${module.waf.id}"
  certificate_arn        = "${data.aws_acm_certificate.main.arn}"
  # ECS
  port                   = 3000
  autoscaling_group_name = "${module.ecs.autoscaling_group_id}"
  security_group_id      = "${module.ecs.security_group_id}"
}

output "alb_endpoint" {
  value = "${module.alb.endpoint}"
}

output "alb_target_group_arn" {
  value = "${module.alb.target_group_arn}"
}
```

## Input
- **vpc_id:** vpc id
- **private_subnet_ids:** array of private subnet ids
- **waf_acl_id:** Regional WAF ACL ID
- **https_only:** Force HTTPS [Default: true]
- **ssl_policy:** TLS policy to enforce. See [docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html) for complete list [Default: `ELBSecurityPolicy-TLS-1-1-2017-01`]
- **certificate_arn:** ARN of AWS certificate
- **port:** ECS port to forward 80/443 traffic to
- **autoscaling_group_name:** ECS auto-scaling group name
- **security_group_id:** ECS security group id

## Output
- **id:** ALB ID
- **arn:** ALB ARN
- **endpoint:** AWS generated URL endpoint
- **target_group_arn:** target group arn
- **security_group_id:** Security group id
