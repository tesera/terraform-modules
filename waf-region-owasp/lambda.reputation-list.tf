data "aws_iam_policy_document" "reputation-list" {
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

resource "aws_iam_policy" "reputation-list" {
  name   = "${local.name}-waf-reputation-list-policy"
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
      "Sid":"CloudWatchLogAccess",
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
      "Sid":"WAFGetAndUpdateIPSet",
      "Action": [
          "waf:GetIPSet",
          "waf:UpdateIPSet"
      ],
      "Resource": [
          "${var.type == "regional" ? aws_wafregional_ipset.reputation-list[0].arn : aws_waf_ipset.reputation-list[0].arn}"
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

resource "aws_iam_role" "reputation-list" {
  name = "${local.name}-waf-reputation-list"
  assume_role_policy = data.aws_iam_policy_document.reputation-list.json
}

resource "aws_iam_role_policy_attachment" "reputation-list" {
  role = aws_iam_role.reputation-list.name
  policy_arn = aws_iam_policy.reputation-list.arn
}

resource "aws_lambda_function" "reputation-list" {
  function_name = "${local.name}-waf-reputation-list"
  filename = "${path.module}/lambda/reputation-list/archive.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda/reputation-list/archive.zip")
  role = aws_iam_role.reputation-list.arn
  handler = "index.handler"
  runtime = "nodejs8.10"
  memory_size = 256
  timeout = 300
  publish = true
  environment {
    variables = {
      API_TYPE = "waf"
      # waf, waf-regional
      LOG_LEVEL = "INFO"
      METRIC_NAME_PREFIX = "${local.name}-waf"
    }
  }
}

## Event Trigger
resource "aws_cloudwatch_event_rule" "reputation-list" {
  name = "${local.name}-waf-reputation-list-event"
  description = "hourly"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "reputation-list" {
  rule = aws_cloudwatch_event_rule.reputation-list.name
  arn = aws_lambda_function.reputation-list.arn
  input = <<JSON
{
  "lists": [
    { "url":"https://www.spamhaus.org/drop/drop.txt" },
    { "url":"https://www.spamhaus.org/drop/edrop.txt" },
    { "url":"https://check.torproject.org/exit-addresses", "prefix":"ExitAddress"},
    {  "url":"https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt" }
  ],
  "region": "${local.region}",
  "ipSetIds": [ "${var.type == "regional" ? aws_wafregional_ipset.reputation-list[0].id : aws_waf_ipset.reputation-list[0].id}" ]
}
JSON
}

resource "aws_lambda_permission" "reputation-list" {
  statement_id  = "${local.name}-waf-reputation-list-event"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reputation-list.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.reputation-list.arn
}

