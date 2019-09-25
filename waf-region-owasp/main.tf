resource "aws_waf_web_acl" "wafACL" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_rule_group.wafBlacklistRuleGroup,
    aws_waf_rule_group.wafOWASPRuleGroup,
    aws_waf_rule.wafWhitelistRule,
  ]

  name        = "${local.name}wafACL"
  metric_name = "${local.name}wafACL"

  default_action {
    type = var.defaultAction
  }

  rules {
    priority = 1
    type     = "GROUP"
    rule_id  = aws_waf_rule_group.wafBlacklistRuleGroup[0].id
    override_action {
      type = "NONE"
    }
  }

  rules {
    priority = 2
    type     = "GROUP"
    rule_id  = aws_waf_rule_group.wafOWASPRuleGroup[0].id
    override_action {
      type = "NONE"
    }
  }

  rules {
    priority = 10
    rule_id  = aws_waf_rule.wafWhitelistRule[0].id
    action {
      type = "ALLOW"
    }
  }

  logging_configuration {
    log_destination = aws_kinesis_firehose_delivery_stream.logging.arn
    // TODO redacte `password`, `mfa/otp`, tokens
    //redacted_fields = {}
  }
}



resource "aws_wafregional_web_acl" "wafACL" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_rule_group.wafBlacklistRuleGroup,
    aws_wafregional_rule_group.wafOWASPRuleGroup,
    aws_wafregional_rule.wafWhitelistRule,
  ]

  name        = "${local.name}wafRegionalACL"
  metric_name = "${local.name}wafRegionalACL"

  default_action {
    type = var.defaultAction
  }

  rule {
    priority = 1
    type     = "GROUP"
    rule_id  = aws_wafregional_rule_group.wafBlacklistRuleGroup[0].id
    override_action {
      type = "NONE"
    }
  }

  rule {
    priority = 2
    type     = "GROUP"
    rule_id  = aws_wafregional_rule_group.wafOWASPRuleGroup[0].id
    override_action {
      type = "NONE"
    }
  }

  rule {
    priority = 10
    rule_id  = aws_wafregional_rule.wafWhitelistRule[0].id
    action {
      type = "ALLOW"
    }
  }

  logging_configuration {
    log_destination = aws_kinesis_firehose_delivery_stream.logging.arn
    // TODO redacte `password`, `mfa/otp`, tokens
    //redacted_fields = {}
  }
}

resource "aws_kinesis_firehose_delivery_stream" "logging" {
  name        = "aws-waf-logs-${local.name}"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.logging.arn
    bucket_arn = "arn:aws:s3:::${local.logging_bucket}"
    prefix     = "/AWSLogs/${local.account_id}/WAF/${local.region}/"
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

resource "aws_iam_policy" "logging" {
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

resource "aws_iam_role_policy_attachment" "logging" {
role       = aws_iam_role.logging.name
policy_arn = aws_iam_policy.logging.arn
}

