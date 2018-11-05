
resource "aws_api_gateway_rest_api" "main" {
  name        = "ci-github-ecr"
  description = "api to handle github webhooks for ECR"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "test" {
  stage_name = "api"
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  deployment_id = "${aws_api_gateway_deployment.main.id}"

  xray_tracing_enabled = false
}

resource "aws_api_gateway_deployment" "main" {
  depends_on  = [
    "aws_api_gateway_method.github"]

  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name  = "api"
}

