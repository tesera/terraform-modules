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

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name = "${local.api_path}"
}

# arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs

# Workaround: https://github.com/terraform-providers/terraform-provider-aws/issues/1153

//resource "aws_api_gateway_stage" "main" {
//  stage_name = "api"
//  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
//  deployment_id = "${aws_api_gateway_deployment.main.id}"
//}




