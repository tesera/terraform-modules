output "id" {
  value = "${aws_cloudfront_distribution.main.id}"
}

output "domain_name" {
  value = "${aws_cloudfront_distribution.main.domain_name}"
}

output "hosted_zone_id" {
  value = "${aws_cloudfront_distribution.main.hosted_zone_id}"
}

output "rest_api_id" {
  value = "${aws_api_gateway_rest_api.main.id}"
}

output "root_resource_id" {
  value = "${aws_api_gateway_rest_api.main.root_resource_id}"
}

output "stage_name" {
  value = "${aws_api_gateway_deployment.main.stage_name}"
}

output "execution_arn" {
  value = "${aws_api_gateway_deployment.main.execution_arn}"
}
