resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets            = [
    "${var.private_subnet_ids}",
  ]

  security_groups    = [
    "${aws_security_group.main.id}",
  ]

  access_logs {
    bucket  = "${aws_s3_bucket.main-s3-logs.id}"
    enabled = false
  }

  tags               = "${merge(local.tags, map(
    "Name", "${local.name}-alb"
  ))}"
}

resource "aws_wafregional_web_acl_association" "main" {
  count        = "${var.waf_acl_id == "" ? 0 : 1}"
  resource_arn = "${aws_lb.main.arn}"
  web_acl_id   = "${var.waf_acl_id}"
}

resource "aws_lb_target_group" "main" {
  name         = "${local.name}-alb-target-group"
  vpc_id       = "${var.vpc_id}"
  protocol     = "HTTP"
  port         = "${var.port}"

  health_check = {
    path    = "/health"
    matcher = 200
  }

  tags         = "${merge(local.tags, map(
    "Name", "${local.name} ALB API"
  ))}"
}

resource "aws_security_group" "main" {
  name   = "${local.name}-alb-security-group"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags   = "${merge(local.tags, map(
    "Name", "${local.name}-alb",
    "Description", "Access to the application ELB"
  ))}"
}

# Logs
# SSE:AWS not supportted
resource "aws_s3_bucket" "main-s3-logs" {
  bucket              = "${local.name}-${terraform.workspace}-alb-access-logs"
  acl                 = "log-delivery-write"
  acceleration_status = "Enabled"

  lifecycle_rule {
    id      = "log"
    enabled = true
    prefix  = ""

    tags {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  tags                = "${merge(local.tags, map(
    "Name", "${local.name} ALB Access Logs"
  ))}"
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
resource "aws_s3_bucket_policy" "main-s3-logs" {
  bucket = "${aws_s3_bucket.main-s3-logs.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {

      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.main-s3-logs.id}/AWSLogs/${local.account_id}/*",
      "Principal": {
        "AWS": [
          "127311923021",
          "033677994240",
          "027434742980",
          "797873946194",
          "985666609251",
          "054676820928",
          "156460612806",
          "652711504416",
          "009996457667",
          "897822967062",
          "582318560864",
          "600734575887",
          "383597477331",
          "114774131450",
          "783225319266",
          "718504428378",
          "507241528517"
        ]
      }
    }
  ]
}
POLICY
}
