# ECS
Auto-scaling cluster of EC2 for ECS

## Features
- Auto-scaling across all private subnets
- CloudWatch logging enabled
- CloudWatch agent for collecting additional metrics
- Inspector agent for allowing running of security assessments in Amazon Inspector
- SSM Agent for allowing shell access from Session AWS Systems Manager

## Connectivity
Install the Session Manager Plugin for the AWS CLI - https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
To start new shell session from aws cli
```bash
aws ssm start-session --target i-00000000000000000 --profile default
```

## Setup

### Prerequisites
Before using this terraform module, the "ec2" and "ecs" AMIs need to be created in all required regions with Packer - https://github.com/tesera/terraform-modules/blob/master/packer/README.md. 

### Module
```hcl-terraform
module "ecs" {
  source            = "git@github.com:tesera/terraform-modules//ecs?ref=v0.3.0"
  name              = "${local.name}"
  vpc_id            = "${module.vpc.id}"
  private_subnet_ids = ["${module.vpc.private_subnet_ids}"]
}

# Logging
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name}-ecs-app"
  retention_in_days = 30
  tags {
    Name = "${local.name}-ecs-app"
  }
}

# Task
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name}-ecs-app"
  requires_compatibilities = [
    "EC2"]
  cpu                      = "${var.docker_cpu}"
  task_role_arn            = "${aws_iam_role.app.arn}"
  execution_role_arn       = "${module.ecs.iam_execution_role_arn}"
  container_definitions = <<DEFINITION
[
  {
    "name": "app",
    "image": "${var.**}",
    "essential": true,
    "cpu": ${var.**},
    "memoryReservation": "${var.**}",
    "environment":[
      { "name":"KEY", "value":"VALUE" }
    ],
    "logConfiguration":{
      "logDriver": "awslogs",
      "options":{
        "awslogs-group":"${aws_cloudwatch_log_group.import.name}",
        "awslogs-region":"${local.aws_region}",
        "awslogs-stream-prefix":"ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_iam_role" "app" {
  name = "${local.name}-app-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "app" {
  name   = "${local.name}-ecs-task-app-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = "${aws_iam_role.app.name}"
  policy_arn = "${aws_iam_policy.app.arn}"
}

```

## Input
- **vpc_id:** vpc id
- **private_subnet_ids:** array of private subnet ids
- **image_id:** override the base image, must be CentOS based (ie has yum, rpm, docker) [Default: AWS ECS-Optimized]
- **instance_type:** override the instance type [Default: t3.micro]
- **min_size:** auto-scaling - min instance count [Default: 2]
- **max_size:** auto-scaling - max instance count [Default: 2]
- **desired_capacity:** auto-scaling - desired instance count [Default: 2]
- **efs_ids:** list of EFS IDs
- **efs_security_group_ids:** list of EFS security groups

## Output
- **name:** ecs cluster name
- **security_group_id:** security group applied, add to ingress on private instance security group
- **iam_role_name:** IAM EC2 role name to allow extending of the role
- **iam_role_arn:** IAM EC2 role arn to allow extending of the role
- **iam_execution_role_name:** IAM task execution role name to allow extending of the role
- **iam_execution_role_arn:** IAM task execution role arn to allow extending of the role
- **billing_suggestion:** comments to improve billing cost
