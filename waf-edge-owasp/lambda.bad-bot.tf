data "aws_iam_policy_document" "bad-bot" {
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

resource "aws_iam_policy" "bad-bot" {
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
      "Sid":"LogAccess",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/*"
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
      "Sid":"WAFGetAndUpdateIPSet",
      "Action": [
          "waf:GetIPSet",
          "waf:UpdateIPSet"
      ],
      "Resource": [
          "${aws_waf_ipset.bad-bot.arn}"
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


resource "aws_iam_role" "bad-bot" {
  name               = "${local.name}-waf-bad-bot"
  assume_role_policy = "${data.aws_iam_policy_document.bad-bot.json}"
}

resource "aws_iam_role_policy_attachment" "bad-bot" {
  role       = "${aws_iam_role.bad-bot.name}"
  policy_arn = "${aws_iam_policy.bad-bot.arn}"
}

data "archive_file" "bad-bot" {
  type        = "zip"
  output_path = "${path.module}/lambda-bad-bot.zip"

  source {
    filename = "index.py"
    content  = "${file("${path.module}/lambda/bad-bot/index.py") }"
  }
}

resource "aws_lambda_function" "bad-bot" {
  function_name = "${local.name}-waf-bad-bot"
  filename      = "${data.archive_file.bad-bot.output_path}"

  source_code_hash = "${data.archive_file.bad-bot.output_base64sha256}"
  role             = "${aws_iam_role.bad-bot.arn}"
  handler          = "index.lambda_handler"
  runtime          = "python3.7"
  memory_size      = 128
  timeout          = 300
  publish          = true
  environment = {
    variables = {
      IP_SET_ID_BAD_BOT = "${aws_waf_ipset.bad-bot.id}"
      LOG_LEVEL = "INFO"
      LOG_TYPE = "edge" # edge, regional
      MAX_AGE_TO_UPDATE = 30
      METRIC_NAME_PREFIX = "${local.name}-waf"
      REGION = "${local.region}"
      SEND_ANONYMOUS_USAGE_DATA = "No"
    }
  }
}




