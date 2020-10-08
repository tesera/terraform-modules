data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${var.source_dir}/../api${local.path_name}.zip"
  source_dir  = var.source_dir
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${local.name}-api-${local.http_method}${local.path_name}"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = 128
  timeout          = 30
  publish          = true

  # Even though empty list are used, still throws error. Docs incorrect
  //  vpc_config {
  //    subnet_ids = ["${var.private_subnet_ids}"]
  //    security_group_ids = ["${var.security_group_ids}"]
  //  }
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # "${aws_api_gateway_deployment.example.execution_arn}/*/${var.http_method}${var.resource_path}"
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${var.rest_api_id}/*/${var.http_method}${var.resource_path}"
}

resource "aws_iam_role" "lambda" {
  name = "${local.name}-api-${local.http_method}${local.path_name}-role"

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

resource "aws_iam_policy" "lambda" {
  name   = "${local.name}-api-${local.http_method}${local.path_name}-policy"
  policy = local.policy
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_role_policy_attachment" "lambda-AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
