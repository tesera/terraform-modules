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

## Viewer Request
resource "aws_iam_role" "viewer_request" {
  name               = "${local.name}-edge-viewer-request"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "viewer_request" {
  role       = aws_iam_role.viewer_request.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "viewer_request" {
  type        = "zip"
  output_path = "${path.module}/lambda-viewer-request.zip"

  source {
    filename = "index.js"
    content  = var.lambda_viewer_request != "" ? var.lambda_viewer_request : file("${path.module}/lambda-viewer-request/index.js")
  }
}

resource "aws_lambda_function" "viewer_request" {
  function_name = "${local.name}-edge-viewer-request"
  filename      = data.archive_file.viewer_request.output_path

  source_code_hash = data.archive_file.viewer_request.output_base64sha256
  role             = aws_iam_role.viewer_request.arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Origin Request
resource "aws_iam_role" "origin_request" {
  name               = "${local.name}-edge-origin-request"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "origin_request" {
  role       = aws_iam_role.origin_request.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "origin_request" {
  type        = "zip"
  output_path = "${path.module}/lambda-origin-request.zip"

  source {
    filename = "index.js"
    content  = var.lambda_origin_request != "" ? var.lambda_origin_request : file("${path.module}/lambda-origin-request/index.js")
  }
}

resource "aws_lambda_function" "origin_request" {
  function_name = "${local.name}-edge-origin-request"
  filename      = data.archive_file.origin_request.output_path

  source_code_hash = data.archive_file.origin_request.output_base64sha256
  role             = aws_iam_role.origin_request.arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Viewer Response
resource "aws_iam_role" "viewer_response" {
  name               = "${local.name}-edge-viewer-response"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "viewer_response" {
  role       = aws_iam_role.viewer_response.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "viewer_response" {
  type        = "zip"
  output_path = "${path.module}/lambda-viewer-response.zip"

  source {
    filename = "index.js"
    content  = var.lambda_viewer_response != "" ? var.lambda_viewer_response : file("${path.module}/lambda-viewer-response/index.js")
  }
}

resource "aws_lambda_function" "viewer_response" {
  function_name = "${local.name}-edge-viewer-response"
  filename      = data.archive_file.viewer_response.output_path

  source_code_hash = data.archive_file.viewer_response.output_base64sha256
  role             = aws_iam_role.viewer_response.arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

## Origin Response
resource "aws_iam_role" "origin_response" {
  name               = "${local.name}-edge-origin-response"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "origin_response" {
  role       = aws_iam_role.origin_response.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "origin_response" {
  type        = "zip"
  output_path = "${path.module}/lambda-origin-response.zip"

  source {
    filename = "index.js"
    content  = var.lambda_origin_response != "" ? var.lambda_origin_response : file("${path.module}/lambda-origin-response/index.js")
  }
}

resource "aws_lambda_function" "origin_response" {
  function_name = "${local.name}-edge-origin-response"
  filename      = data.archive_file.origin_response.output_path

  source_code_hash = data.archive_file.origin_response.output_base64sha256
  role             = aws_iam_role.origin_response.arn
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

