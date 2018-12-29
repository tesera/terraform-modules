# Lambda@Edge
data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name}-edge-viewer-response"
  assume_role_policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

## Request
data "archive_file" "viewer_request" {
  type        = "zip"
  output_path = "${path.module}/lambda-viewer-request.zip"

  source {
    filename = "index.js"
    content  = "${var.lambda_viewer_request != "" ? var.lambda_viewer_request : file("${path.module}/lambda-viewer-request/index.js") }"
  }
}

resource "aws_lambda_function" "viewer_request" {
  provider      = "aws.edge"
  function_name = "${local.name}-edge-viewer-request"
  filename      = "${data.archive_file.viewer_request.output_path}"

  source_code_hash = "${data.archive_file.viewer_request.output_base64sha256}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Response

data "archive_file" "viewer_response" {
  type        = "zip"
  output_path = "${path.module}/lambda-viewer-response.zip"

  source {
    filename = "index.js"
    content  = "${var.lambda_viewer_response != "" ? var.lambda_viewer_response : file("${path.module}/lambda-viewer-response/index.js") }"
  }
}

resource "aws_lambda_function" "viewer_response" {
  provider      = "aws.edge"
  function_name = "${local.name}-edge-viewer-response"
  filename      = "${data.archive_file.viewer_response.output_path}"

  source_code_hash = "${data.archive_file.viewer_response.output_base64sha256}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}


