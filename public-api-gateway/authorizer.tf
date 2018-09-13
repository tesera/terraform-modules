resource "aws_api_gateway_authorizer" "main" {
  name                   = "${local.name}-authorizer"
  rest_api_id            = "${aws_api_gateway_rest_api.main.id}"
  authorizer_uri         = "${aws_lambda_function.authorizer.invoke_arn}"
  authorizer_credentials = "${aws_iam_role.main.arn}"
}

resource "aws_iam_role" "main" {
  name = "${local.name}-api-invocation-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authorizer" {
  name = "${local.name}-api-authorizer-policy"
  role = "${aws_iam_role.main.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["lambda:InvokeFunction"],
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.authorizer.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "authorizer" {
  name = "${local.name}-api-authorizer-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "authorizer" {
  role       = "${aws_iam_role.authorizer.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "authorizer" {
  function_name    = "${local.name}-api-authorizer"
  filename         = "${data.archive_file.authorizer.output_path}"
  source_code_hash = "${data.archive_file.authorizer.output_base64sha256}"
  role             = "${aws_iam_role.authorizer.arn}"
  handler          = "${var.handler}"
  runtime          = "${var.runtime}"
  memory_size      = "${var.memory_size}"
  timeout          = "${var.timeout}"
  publish          = true,

  // Has no need to be in a VPC

  // TODO pass in var
  environment {
    variables {
      CLIENT_ID = ""
      CLIENT_SECRET = ""
    }
  }

  tags {
    Name = "Authorizer for API Gateway"
    Terraform = true
  }
}

data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "${local.authorizer_dir}/../authorizer.zip"
  source_dir  = "${local.authorizer_dir}"
}
