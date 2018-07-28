# Enable Logging - TODO move to global setup
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = "${aws_iam_role.main-logs.arn}"
}

resource "aws_iam_role" "main-logs" {
  name               = "${var.name}-apig-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-logs" {
  role       = "${aws_iam_role.main-logs.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Setup APIG
resource "aws_api_gateway_rest_api" "main" {
  name        = "${local.name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# aws_api_gateway_deployment.main: Error creating API Gateway Deployment: BadRequestException: The REST API doesn't contain any methods
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name = "${local.stage_name}"
}

# Hook to build Endpoints
//resource "null_resource" "pre-flight" {
//  provisioner "local-exec" {
//    command = "node routes.js "
//  }
//}

data "external" "endpoints" {
  program = ["node", "${path.module}/routes.js", "${var.lambda_dir}", "${var.lambda_config_path}"]
}

# arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs

# Workaround: https://github.com/terraform-providers/terraform-provider-aws/issues/1153




