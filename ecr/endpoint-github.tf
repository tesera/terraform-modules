resource "aws_api_gateway_resource" "github" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  parent_id   = "${aws_api_gateway_rest_api.main.root_resource_id}"
  path_part   = "github"
}

resource "aws_api_gateway_method" "github" {
  rest_api_id        = "${aws_api_gateway_rest_api.main.id}"
  resource_id        = "${aws_api_gateway_resource.github.id}"
  http_method        = "POST"
  authorization      = "NONE"
  request_parameters = {
    "method.request.header.X-GitHub-Event"    = true
    "method.request.header.X-GitHub-Delivery" = true
  }
}

resource "aws_api_gateway_integration" "github" {
  rest_api_id             = "${aws_api_gateway_rest_api.main.id}"
  resource_id             = "${aws_api_gateway_resource.github.id}"
  http_method             = "${aws_api_gateway_method.github.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${local.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.github.arn}/invocations"
  request_parameters      = {
    "integration.request.header.X-GitHub-Event" = "method.request.header.X-GitHub-Event"
  }
  request_templates       = {
    "application/json" = <<EOF
{
  "body" : $input.json('$'),
  "header" : {
    "X-GitHub-Event": "$input.params('X-GitHub-Event')",
    "X-GitHub-Delivery": "$input.params('X-GitHub-Delivery')"
  }
}
EOF
  }
}

// CORS

resource "aws_api_gateway_method" "github-cors" {
  rest_api_id   = "${aws_api_gateway_rest_api.main.id}"
  resource_id   = "${aws_api_gateway_resource.github.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "github-cors" {
  rest_api_id       = "${aws_api_gateway_rest_api.main.id}"
  resource_id       = "${aws_api_gateway_resource.github.id}"
  http_method       = "${aws_api_gateway_method.github.http_method}"
  type              = "MOCK"

  request_templates = {
    "application/json" = <<PARAMS
{ "statusCode": 200 }
PARAMS
  }
}

resource "aws_api_gateway_integration_response" "github-cors" {
  depends_on          = [
    "aws_api_gateway_integration.github",
  ]

  rest_api_id         = "${aws_api_gateway_rest_api.main.id}"
  resource_id         = "${aws_api_gateway_resource.github.id}"
  http_method         = "${aws_api_gateway_method.github.http_method}"
  status_code         = "200"

  response_templates {
    "application/json" = "$input.path('$')"
  }

  response_parameters = {
    "method.response.header.Content-Type"                 = "integration.response.header.Content-Type"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  selection_pattern   = ".*"
}

resource "aws_api_gateway_method_response" "github-cors" {
  depends_on          = [
    "aws_api_gateway_method.github",
  ]

  rest_api_id         = "${aws_api_gateway_rest_api.main.id}"
  resource_id         = "${aws_api_gateway_resource.github.id}"
  http_method         = "${aws_api_gateway_method.github.http_method}"
  status_code         = "200"

  response_models     = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}


resource "aws_iam_policy" "github" {
  name        = "ci-github-ecr-policy"
  path        = "/"
  description = "lambda pr policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "codepipeline:CreatePipeline",
                "codepipeline:DeletePipeline",
                "codepipeline:GetPipelineState",
                "codepipeline:ListPipelines",
                "codepipeline:GetPipeline",
                "codepipeline:UpdatePipeline",
                "iam:PassRole"
            ],
            "Resource": [
                "*"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "github" {
  name               = "ci-github-ecr-role"
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

resource "aws_iam_role_policy_attachment" "github" {
  role       = "${aws_iam_role.github.name}"
  policy_arn = "${aws_iam_policy.github.arn}"
}

resource "aws_lambda_function" "github" {
  filename         = "${data.archive_file.github.output_path}"
  source_code_hash = "${data.archive_file.github.output_base64sha256}"
  function_name    = "ci-webhook-github"
  role             = "${aws_iam_role.github.arn}"
  handler          = "index.handler"
  memory_size      = 256
  timeout          = 300
  runtime          = "nodejs8.10"
  environment {
    variables = {
      CODEPIPELINE_TEMPLATE = ""
    }
  }
}

data "archive_file" "github" {
  type        = "zip"
  output_path = "${path.module}/handler.zip"
  source_dir  = "${path.module}/webhook-github"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.github.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn    = "arn:aws:execute-api:${local.aws_region}:${local.account_id}:${aws_api_gateway_rest_api.main.id}/*/POST/github"
}
