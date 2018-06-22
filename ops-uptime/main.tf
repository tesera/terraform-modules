
resource "aws_sns_topic" "main" {
  name = "${var.name}-uptime-alarm"
  provider = "aws.edge"

  provisioner "local-exec" {
    command = "aws sns subscribe --profile ${local.profile} --topic-arn ${self.arn} --region ${local.aws_region} --protocol email --notification-endpoint ${var.sns_subscribe_primary}"
  }
}

resource "aws_route53_health_check" "main" {
  fqdn              = "${var.domain}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "${var.resource_path}"
  failure_threshold = "${failure_threshold}"
  request_interval  = "${request_interval}"
  measure_latency   = true
  regions = [   // restrict to min allowed due to WAF ip limit
    "us-east-1",
    "us-west-1",
    "us-west-2"
  ]

  tags              = {
    Name = "${var.name}-health-check"
  }
}

resource "aws_cloudwatch_metric_alarm" "main" {
  provider            = "aws.edge"
  alarm_name          = "${var.env}-uptime-failed"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  unit                = "None"
  dimensions = {
    HealthCheckId     = "${aws_route53_health_check.main.id}"
  }
  alarm_actions       = ["${aws_sns_topic.main.arn}"]
  ok_actions          = ["${aws_sns_topic.main.arn}"]
}

