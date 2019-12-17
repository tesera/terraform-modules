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


## Template
resource "aws_iam_role" "lambda" {
  count              = length(keys(var.lambda))
  name               = "${local.name}-edge-${keys(var.lambda)[count.index]}"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count      = length(keys(var.lambda))
  role       = aws_iam_role.lambda[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  count       = length(keys(var.lambda))
  type        = "zip"
  output_path = "${path.module}/lambda-${keys(var.lambda)[count.index]}.zip"

  source {
    filename = "index.js"
    content  = var.lambda[keys(var.lambda)[count.index]]
  }
}

resource "aws_lambda_function" "lambda" {
  count            = length(keys(var.lambda))
  provider         = "aws.edge"
  function_name    = "${local.name}-edge-${keys(var.lambda)[count.index]}"
  filename         = data.archive_file.lambda[count.index].output_path
  source_code_hash = data.archive_file.lambda[count.index].output_base64sha256
  role             = aws_iam_role.lambda[count.index].arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  memory_size      = 128
  timeout          = 1
  publish          = true
}
