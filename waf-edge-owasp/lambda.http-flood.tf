data "aws_iam_policy_document" "http-flood" {
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

// TODO harden `S3AccessGeneral` & `S3AccessPut`
// TODO change config file path
resource "aws_iam_policy" "http-flood" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"LambdaAccess",
      "Action": "lambda:InvokeFunction",
      "Resource": [
          "arn:aws:lambda:${local.region}:${local.account_id}:function:*"
      ],
      "Effect": "Allow"
    }
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
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      "Resource": [
          "arn:aws:s3:::${local.logging_bucket}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3AccessGeneral",
      "Action": [
        "s3:CreateBucket",
        "s3:GetBucketNotification",
        "s3:PutBucketNotification"
      ],
      "Resource": [
        "arn:aws:s3:::*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3AccessPut",
      "Action": "s3:PutObject",
      "Resource": [
          "arn:aws:s3:::${local.logging_bucket}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "waf:GetWebACL",
        "waf:UpdateWebACL"
      ],
      "Resource": [
        "${aws_waf_web_acl.wafrOwaspACL.arn}",
        "arn:aws:waf::${local.account_id}:rule/*",
        "arn:aws:waf::${local.account_id}:ratebasedrule/*"
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
          "arn:aws:waf::852636546550:ipset/*"
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
    },
    {
      "Sid":"WAFLogsAccess",
      "Action": [
        "waf:PutLoggingConfiguration",
        "waf:DeleteLoggingConfiguration"
      ],
      "Resource": [
        "${aws_waf_web_acl.wafOwaspACL.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"WAFLogsAccess",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": "waf.amazonaws.com"
        }
      },
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": [
        "arn:aws:iam::*:role/aws-service-role/waf.amazonaws.com/AWSServiceRoleForWAFLogging"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"WAFRateBasedRuleAccess",
      "Action": [
        "waf:GetRateBasedRule",
        "waf:CreateRateBasedRule",
        "waf:UpdateRateBasedRule",
        "waf:DeleteRateBasedRule",
        "waf:ListRateBasedRules",
        "waf:UpdateWebACL"
      ],
      "Resource": [
        "arn:aws:waf::${local.account_id}:ratebasedrule/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "waf:GetRule",
        "waf:GetIPSet",
        "waf:UpdateIPSet"
      ],
      "Resource": [
        "arn:aws:waf::${local.account_id}:rule/*"
      ],
      "Effect": "Allow"
    }




  ]
}
POLICY
}


resource "aws_iam_role" "http-flood" {
  name               = "${local.name}-waf-http-flood"
  assume_role_policy = "${data.aws_iam_policy_document.http-flood.json}"
}

resource "aws_iam_role_policy_attachment" "http-flood" {
  role       = "${aws_iam_role.http-flood.name}"
  policy_arn = "${aws_iam_policy.http-flood.arn}"
}

data "archive_file" "http-flood" {
  type        = "zip"
  output_path = "${path.module}/lambda-http-flood.zip"

  source {
    filename = "index.py"
    content  = "${file("${path.module}/lambda/http-flood/index.py") }"
  }
}

resource "aws_lambda_function" "http-flood" {
  function_name = "${local.name}-waf-http-flood"
  filename      = "${data.archive_file.http-flood.output_path}"

  source_code_hash = "${data.archive_file.http-flood.output_base64sha256}"
  role             = "${aws_iam_role.http-flood.arn}"
  handler          = "index.lambda_handler"
  runtime          = "python3.7"
  memory_size      = 128
  timeout          = 300
  publish          = true
  environment = {
    variables = {
      API_TYPE = "waf"
      LOG_LEVEL = "INFO"
    }
  }
}




