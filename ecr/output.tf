
output "url" {
  value = "${aws_api_gateway_deployment.main.invoke_url}"
}
