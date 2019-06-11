resource "aws_waf_web_acl" "wafrOwaspACL" {
  depends_on = [
    "aws_waf_rate_based_rule.wafHTTPFloodRule",
    "aws_waf_rule.wafgSQLInjectionRule",
    "aws_waf_rule.wafrXSSRule",
    "aws_waf_rule.wafgAdminAccessRule",
    "aws_waf_rule.wafgAuthTokenRule",
    "aws_waf_rule.wafgCSRFRule",
    "aws_waf_rule.wafgPathsRule",
    "aws_waf_rule.wafgServerSideIncludeRule",
    "aws_waf_rule.wafgIpBlackListRule",
    "aws_waf_rule.wafgIpWhiteListRule",
  ]

  name        = "${local.name}wafrOwaspACL"
  metric_name = "${local.name}wafrOwaspACL"

  default_action {
    type = "${var.defaultAction}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 5
    rule_id  = "${aws_waf_rate_based_rule.wafHTTPFloodRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = "${aws_waf_rule.wafrSizeRestrictionRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_waf_rule.wafgIpBlackListRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = "${aws_waf_rule.wafgAuthTokenRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_waf_rule.wafgSQLInjectionRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_waf_rule.wafrXSSRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_waf_rule.wafgPathsRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_waf_rule.wafgCSRFRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 90
    rule_id  = "${aws_waf_rule.wafgServerSideIncludeRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 100
    rule_id  = "${aws_waf_rule.wafgAdminAccessRule.id}"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 999
    rule_id  = "${aws_waf_rule.wafgIpWhiteListRule.id}"
  }

  logging_configuration {
    log_destination = "${aws_kinesis_firehose_delivery_stream.logging.arn}"
    // TODO redacte `password`, `mfa/otp`, tokens
    //redacted_fields = {}
  }
}

data "aws_caller_identity" "current" {}
resource "aws_kinesis_firehose_delivery_stream" "logging" {
  name        = "${local.name}-waf-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.logging.arn}"
    bucket_arn = "${var.logging_bucket_arn}"
    prefix     = "/AWSLogs/${data.aws_caller_identity.current.account_id}/WAF/us-east-1/"
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
