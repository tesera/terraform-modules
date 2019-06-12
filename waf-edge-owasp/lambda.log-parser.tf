data "aws_iam_policy_document" "log-parser" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "log-parser" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"CloudWatchAccess",
      "Action": "cloudwatch:GetMetricStatistics",
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3Access",
      "Action": "s3:GetObject",
      "Resource": [
          "arn:aws:s3:::${local.logging_bucket}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3Access",
      "Action": "s3:PutObject",
      "Resource": [
          "arn:aws:s3:::${local.logging_bucket}/AWSWAFSecurityAutomations-waf_log_out.json",
          "arn:aws:s3:::${local.logging_bucket}/AWSWAFSecurityAutomations-waf_log_conf.json",
          "arn:aws:s3:::${local.logging_bucket}/AWSWAFSecurityAutomations-app_log_out.json",
          "arn:aws:s3:::${local.logging_bucket}/AWSWAFSecurityAutomations-app_log_conf.json"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"WAFGetAndUpdateIPSet",
      "Action": [
          "waf:GetIPSet",
          "waf:UpdateIPSet"
      ],
      "Resource": [
          "${aws_waf_ipset.blacklist.arn}",
          "${aws_waf_ipset.http-flood.arn}",
          "${aws_waf_ipset.scanners-probes.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"WAFGetChangeToken",
      "Action": "waf:GetChangeToken",
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY
}


resource "aws_iam_role" "log-parser" {
  name               = "${local.name}-waf-log-parser"
  assume_role_policy = "${data.aws_iam_policy_document.log-parser.json}"
}

resource "aws_iam_role_policy_attachment" "log-parser" {
  role       = "${aws_iam_role.log-parser.name}"
  policy_arn = "${aws_iam_policy.log-parser.arn}"
}

data "archive_file" "log-parser" {
  type        = "zip"
  output_path = "${path.module}/lambda-log-parser.zip"

  source {
    filename = "index.py"
    content  = "${file("${path.module}/lambda/log-parser/index.py") }"
  }
}

resource "aws_lambda_function" "log-parser" {
  function_name = "${local.name}-waf-log-parser"
  filename      = "${data.archive_file.log-parser.output_path}"

  source_code_hash = "${data.archive_file.log-parser.output_base64sha256}"
  role             = "${aws_iam_role.log-parser.arn}"
  handler          = "index.lambda_handler"
  runtime          = "python3.7"
  memory_size      = 512
  timeout          = 300
  publish          = true
  environment = {
    variables = {
      APP_ACCESS_LOG_BUCKET = "${local.logging_bucket}"
      WAF_ACCESS_LOG_BUCKET = "${local.logging_bucket}"
      IP_SET_ID_HTTP_FLOOD = "${aws_waf_ipset.http-flood.id}"
      IP_SET_ID_SCANNERS_PROBES = "${aws_waf_ipset.scanners-probes.id}"
      LIMIT_IP_ADDRESS_RANGES_PER_IP_MATCH_CONDITION = 10000
      LOG_LEVEL = "INFO"
      LOG_TYPE = "cloudfront" # TODO make param, allow ALB, APIG
      MAX_AGE_TO_UPDATE = 30
      METRIC_NAME_PREFIX = "${local.name}-waf"
      REGION = "${local.region}"
      SEND_ANONYMOUS_USAGE_DATA = "No"
    }
  }
}




