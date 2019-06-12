data "aws_iam_policy_document" "helper" {
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

resource "aws_iam_policy" "helper" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
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
    }
  ]
}
POLICY
}


resource "aws_iam_role" "helper" {
  name               = "${local.name}-waf-helper"
  assume_role_policy = "${data.aws_iam_policy_document.helper.json}"
}

resource "aws_iam_role_policy_attachment" "helper" {
  role       = "${aws_iam_role.helper.name}"
  policy_arn = "${aws_iam_policy.helper.arn}"
}

data "archive_file" "helper" {
  type        = "zip"
  output_path = "${path.module}/lambda-helper.zip"

  source {
    filename = "index.py"
    content  = "${file("${path.module}/lambda/helper/index.py") }"
  }
}

resource "aws_lambda_function" "helper" {
  function_name = "${local.name}-waf-helper"
  filename      = "${data.archive_file.helper.output_path}"

  source_code_hash = "${data.archive_file.helper.output_base64sha256}"
  role             = "${aws_iam_role.helper.arn}"
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




