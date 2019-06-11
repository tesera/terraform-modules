resource "aws_wafregional_web_acl" "wafrOwaspACL" {
  depends_on = [
    "aws_wafregional_rule.wafgAdminAccessRule",
    "aws_wafregional_rule.wafgAuthTokenRule",
    "aws_wafregional_rule.wafgCSRFRule",
    "aws_wafregional_rule.wafgPathsRule",
    "aws_wafregional_rule.wafgServerSideIncludeRule",
    "aws_wafregional_rule.wafrXSSRule",
    "aws_wafregional_rule.wafgIpBlackListRule",
    "aws_wafregional_rule.wafgIpWhiteListRule",
  ]

  name        = "${local.name}wafrOwaspACL"
  metric_name = "${local.name}wafrOwaspACL"

  default_action {
    type = "${var.defaultAction}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = "${aws_wafregional_rule.wafrSizeRestrictionRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_wafregional_rule.wafgIpBlackListRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = "${aws_wafregional_rule.wafgAuthTokenRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_wafregional_rule.wafgSQLiRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_wafregional_rule.wafrXSSRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_wafregional_rule.wafgPathsRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_wafregional_rule.wafgCSRFRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 90
    rule_id  = "${aws_wafregional_rule.wafgServerSideIncludeRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 100
    rule_id  = "${aws_wafregional_rule.wafgAdminAccessRule.id}"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 999
    rule_id  = "${aws_wafregional_rule.wafgIpWhiteListRule.id}"
  }

  logging_configuration {
    log_destination = "${aws_kinesis_firehose_delivery_stream.logging.arn}"
    // TODO redacte `password`, `mfa/otp`, tokens
    //redacted_fields = {}
  }
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_kinesis_firehose_delivery_stream" "logging" {
  name        = "${local.name}-waf-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.logging.arn}"
    bucket_arn = "${var.logging_bucket_arn}"
    prefix     = "/AWSLogs/${data.aws_caller_identity.current.account_id}/WAF/${data.aws_region.current.name}/"
  }
}

resource "aws_iam_role" "logging" {
  name = "${local.name}-waf-stream-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
