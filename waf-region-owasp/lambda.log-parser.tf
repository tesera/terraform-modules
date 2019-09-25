data "aws_iam_policy_document" "log-parser" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "log-parser" {
  name   = "${local.name}-waf-log-parser-policy"
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
      "Sid":"S3AccessGet",
      "Action": "s3:GetObject",
      "Resource": [
          "arn:aws:s3:::${local.logging_bucket}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3AccessPut",
      "Action": "s3:PutObject",
      "Resource": [
          "arn:aws:s3:::${local.logging_bucket}/${local.name}-waf_log_out.json",
          "arn:aws:s3:::${local.logging_bucket}/${local.name}-waf_log_conf.json",
          "arn:aws:s3:::${local.logging_bucket}/${local.name}-app_log_out.json",
          "arn:aws:s3:::${local.logging_bucket}/${local.name}-app_log_conf.json"
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
          "${var.type == "regional" ? aws_wafregional_ipset.blacklist[0].arn : aws_waf_ipset.blacklist[0].arn}",
          "${var.type == "regional" ? aws_wafregional_ipset.http-flood[0].arn : aws_waf_ipset.http-flood[0].arn}",
          "${var.type == "regional" ? aws_wafregional_ipset.scanners-probes[0].arn : aws_waf_ipset.scanners-probes[0].arn}"
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
  name = "${local.name}-waf-log-parser"
  assume_role_policy = data.aws_iam_policy_document.log-parser.json
}

resource "aws_iam_role_policy_attachment" "log-parser" {
  role = aws_iam_role.log-parser.name
  policy_arn = aws_iam_policy.log-parser.arn
}

data "archive_file" "log-parser" {
  type = "zip"
  output_path = "${path.module}/lambda-log-parser.zip"

  source {
    filename = "index.py"
    content = file("${path.module}/lambda/log-parser/index.py")
  }
}

resource "aws_lambda_function" "log-parser" {
  function_name = "${local.name}-waf-log-parser"
  filename = data.archive_file.log-parser.output_path

  source_code_hash = data.archive_file.log-parser.output_base64sha256
  role = aws_iam_role.log-parser.arn
  handler = "index.lambda_handler"
  runtime = "python3.7"
  memory_size = 512
  timeout = 300
  publish = true
  environment {
    variables = {
      STACK_NAME = local.name
      APP_ACCESS_LOG_BUCKET = local.logging_bucket
      WAF_ACCESS_LOG_BUCKET = local.logging_bucket
      IP_SET_ID_HTTP_FLOOD = var.type == "regional" ? aws_wafregional_ipset.http-flood[0].id : aws_waf_ipset.http-flood[0].id
      IP_SET_ID_SCANNERS_PROBES = var.type == "regional" ? aws_wafregional_ipset.scanners-probes[0].id : aws_waf_ipset.scanners-probes[0].id
      LIMIT_IP_ADDRESS_RANGES_PER_IP_MATCH_CONDITION = 10000
      LOG_LEVEL = "INFO"
      LOG_TYPE = "cloudfront"
      # waf, alb, cloudfront
      MAX_AGE_TO_UPDATE = 30
      METRIC_NAME_PREFIX = "${local.name}-waf"
      REGION = local.region
    }
  }
}

resource "aws_lambda_permission" "log-parser" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log-parser.function_name
  principal = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::${local.logging_bucket}"
}

resource "aws_s3_bucket_notification" "log-parser" {
  bucket = local.logging_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.log-parser.arn
    events = [
      "s3:ObjectCreated:*",
    ]
    filter_prefix = "AWSLogs/${local.account_id}/CloudFront/*"
    filter_suffix = ".gz"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.log-parser.arn
    events = [
      "s3:ObjectCreated:*",
    ]
    filter_prefix = "AWSLogs/${local.account_id}/ALB/*"
    filter_suffix = ".gz"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.log-parser.arn
    events = [
      "s3:ObjectCreated:*",
    ]
    filter_prefix = "AWSLogs/${local.account_id}/WAF/*"
    filter_suffix = ".gz"
  }
}

# TODO don't update file if already exists
resource "aws_s3_bucket_object" "app-log-parser" {
  bucket = local.logging_bucket
  key = "/${local.name}-app_log_conf.json"
  content = <<JSON
{
    "general": {
        "errorThreshold": ${var.errorThreshold},
        "blockPeriod": ${var.blockPeriod},
        "errorCodes": ["400", "401", "403", "404", "405"]
    },
    "uriList": {}
}
JSON

}

resource "aws_s3_bucket_object" "waf-log-parser" {
bucket  = local.logging_bucket
key     = "/${local.name}-waf_log_conf.json"
content = <<JSON
{
    "general": {
        "errorThreshold": ${var.errorThreshold},
        "blockPeriod": ${var.blockPeriod},
        "ignoredSufixes": []
    },
    "uriList": {}
}
JSON

}

