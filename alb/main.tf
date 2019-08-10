resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = var.private_subnet_ids

  security_groups = [
    aws_security_group.main.id,
  ]

  access_logs {
    bucket  = local.logging_bucket
    prefix  = "AWSLogs/${local.account_id}/ALB/${local.name}-alb/"
    enabled = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name}-alb"
    },
  )
}

resource "aws_wafregional_web_acl_association" "main" {
  count        = var.waf_acl_id == "" ? 0 : 1
  resource_arn = aws_lb.main.arn
  web_acl_id   = var.waf_acl_id
}

resource "aws_lb_target_group" "main" {
  name     = "${local.name}-alb-target-group"
  vpc_id   = var.vpc_id
  protocol = "HTTP"
  port     = var.port

  health_check {
    path    = "/health"
    matcher = 200
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name} ALB API"
    },
  )
}

resource "aws_security_group" "main" {
  name   = "${local.name}-alb-security-group"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
    local.tags,
    {
      "Name"        = "${local.name}-alb"
      "Description" = "Access to the application ELB"
    },
  )
}

