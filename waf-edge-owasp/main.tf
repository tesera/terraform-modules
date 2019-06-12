resource "aws_waf_web_acl" "wafrOwaspACL" {
  depends_on = [
    "aws_waf_rate_based_rule.wafHTTPFloodRule",
    "aws_waf_rule.wafSQLInjectionRule",
    "aws_waf_rule.wafXSSRule",
    "aws_waf_rule.wafAdminAccessRule",
    "aws_waf_rule.wafAuthTokenRule",
    "aws_waf_rule.wafCSRFRule",
    "aws_waf_rule.wafPathsRule",
    "aws_waf_rule.wafServerSideIncludeRule",
    "aws_waf_rule.wafBlacklistRule",
    "aws_waf_rule.wafWhitelistRule",
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

    priority = 10
    rule_id  = "${aws_waf_rule.wafSizeRestrictionRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_waf_rule.wafAuthTokenRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = "${aws_waf_rule.wafSQLInjectionRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_waf_rule.wafXSSRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_waf_rule.wafPathsRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_waf_rule.wafCSRFRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 70
    rule_id  = "${aws_waf_rule.wafServerSideIncludeRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_waf_rule.wafAdminAccessRule.id}"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 100
    rule_id  = "${aws_waf_rule.wafWhitelistRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 900
    rule_id  = "${aws_waf_rule.wafBlacklistRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 910
    rule_id  = "${aws_waf_rule.wafHTTPFloodRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 920
    rule_id  = "${aws_waf_rule.wafScannersProbesRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 930
    rule_id  = "${aws_waf_rule.wafReputationListRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 940
    rule_id  = "${aws_waf_rule.wafBadBotRule.id}"
  }



  logging_configuration {
    log_destination = "${aws_kinesis_firehose_delivery_stream.logging.arn}"
    // TODO redacte `password`, `mfa/otp`, tokens
    //redacted_fields = {}
  }
}

resource "aws_kinesis_firehose_delivery_stream" "logging" {
  name        = "aws-waf-logs-${local.name}"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.firehose.arn}"
    bucket_arn = "arn:aws:s3:::${local.logging_bucket}"
    prefix     = "/AWSLogs/${local.account_id}/WAF/us-east-1/"
  }
}

resource "aws_iam_role" "firehose" {
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

resource "aws_iam_policy" "firehose" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"CloudWatchAccess",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/kinesisfirehose/${local.name}-waf-stream:*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"KinesisAccess",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords"
      ],
      "Resource": [
        "${aws_kinesis_firehose_delivery_stream.logging.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3Access",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.logging_bucket}",
        "arn:aws:s3:::${local.logging_bucket}/*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = "${aws_iam_role.firehose.name}"
  policy_arn = "${aws_iam_policy.firehose.arn}"
}
