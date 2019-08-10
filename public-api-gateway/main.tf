# Setup APIG
resource "aws_api_gateway_rest_api" "main" {
  name = local.name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "test" {
  stage_name    = local.stage_name
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id

  xray_tracing_enabled = var.xray
}

# aws_api_gateway_deployment.main: Error creating API Gateway Deployment: BadRequestException: The REST API doesn't contain any methods
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = local.stage_name
}

# Hook to build Endpoints
//resource "null_resource" "pre-flight" {
//  provisioner "local-exec" {
//    command = "node routes.js "
//  }
//}

data "external" "endpoints" {
  program = ["node", "${path.module}/routes.js", var.lambda_dir, var.lambda_config_path]
}

# arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs
# Workaround: https://github.com/terraform-providers/terraform-provider-aws/issues/1153
