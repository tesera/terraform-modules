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
      "Effect": "Allow",
      "Sid": ""
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
      "Action": "lambda:InvokeFunction",
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
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_function" "authorizer" {
  function_name    = "${local.name}-api-authorizer"
  filename         = "${var.authorizer_path}"
  source_code_hash = "${var.authorizer_base64sha256}"
  role             = "${aws_iam_role.authorizer.arn}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 30
  publish          = true,

  // TODO
  //  vpc_config {
  //    subnet_ids = ["${var.private_subnet_ids}"]
  //    security_group_ids = ["${aws_security_group.poller.id}"]
  //  }

  // TODO pass in var
  environment {
    variables {
      CLIENT_ID = ""
      CLIENT_SECRET = ""
    }
  }
}


# Default Authorizer
data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "${path.module}/authorizer.zip"
  source_dir  = "${path.module}/authorizer"
}
