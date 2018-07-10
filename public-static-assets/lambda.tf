data "archive_file" "response_headers" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    filename = "index.js"
    content  = "${var.lambda_edge_content != "" ? var.lambda_edge_content : file("${path.module}/lambda/index.js") }"
  }
}

resource "aws_lambda_function" "response_headers" {
  provider      = "aws.edge"
  function_name = "${local.name}-edge-response"

  # ${var.env}-${var.name}-edge-response-2017-12-01 # HACK for dev
  # function_name = "qa-emis-registration-website-edge-response-headers-2017-11-28"   # HACK for fixing AWS - QA Only
  filename = "${data.archive_file.response_headers.output_path}"

  source_code_hash = "${data.archive_file.response_headers.output_base64sha256}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 1
  publish          = true
}

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
  name               = "${local.name}-edge-response"
  assume_role_policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
