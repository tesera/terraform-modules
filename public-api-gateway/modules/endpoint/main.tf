resource "aws_api_gateway_method" "main" {
  rest_api_id          = var.rest_api_id
  resource_id          = var.resource_id
  http_method          = var.http_method
  authorization        = var.authorization
  authorizer_id        = var.authorizer_id
  authorization_scopes = var.authorization_scopes
}

resource "aws_api_gateway_method_settings" "main" {
  depends_on = [
    aws_api_gateway_method.main,
  ]

  rest_api_id = var.rest_api_id
  stage_name  = var.stage_name
  method_path = var.resource_path / aws_api_gateway_method.main.http_method

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.main.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}
