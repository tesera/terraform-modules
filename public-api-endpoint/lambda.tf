resource "aws_lambda_function" "lambda" {
  function_name    = "${local.name}-api-${local.http_method}${local.path_name}"
  filename         = "${local.lambda_path}"
  source_code_hash = "${local.lambda_base64sha256}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 30
  publish          = true

  //  vpc_config {
  //    subnet_ids = ["${var.private_subnet_ids}"]
  //    security_group_ids = ["${aws_security_group.poller.id}"]
  //  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name}-api-${local.http_method}${local.path_name}-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  # "${aws_api_gateway_deployment.example.execution_arn}/*/${var.http_method}${var.resource_path}"
  source_arn    = "arn:aws:execute-api:${local.aws_region}:${local.account_id}:${var.rest_api_id}/*/${var.http_method}${var.resource_path}"
}

resource "aws_iam_policy" "lambda" {
  name   = "${local.name}-api-${local.http_method}${local.path_name}-policy"
  policy = "${local.lambda_policy}"
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.lambda.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda-AWSLambdaBasicExecutionRole" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
 }
