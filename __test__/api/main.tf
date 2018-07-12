//terraform {
//  backend "s3" {
//    bucket         = "terraform-state"
//    key            = "app/terraform.tfstate"
//    region         = "ca-central-1"
//    profile        = "tesera"
//    dynamodb_table = "terraform-state"
//  }
//}

locals {
  aws_region  = "ca-central-1"
  profile     = "tesera"
  name        = "tesera-modules_test"
  domain_root = "tesera.com"
  domain      = "test.tesera.com"
}

provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.profile}"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${local.profile}"
  alias   = "edge"
}

# WAF
module "waf" {
  source        = "../../waf-owasp"
  name          = "${local.name}"
  defaultAction = "ALLOW"
}

# API
## DNS
data "aws_route53_zone" "main" {
  name = "${local.domain_root}."
}

resource "aws_route53_record" "main" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${local.domain}"
  type    = "A"
  alias   = {
    name                   = "${module.api.domain_name}"
    zone_id                = "${module.api.hosted_zone_id}"
    evaluate_target_health = true
  }
}

## TLS
data "aws_acm_certificate" "main" {
  provider = "aws.edge"
  domain   = "${local.domain}"
  statuses = [
    "ISSUED"]
}

## APIG
module "api" {
  source                  = "../../public-api-gateway"
  name                    = "${local.name}"

  aliases                 = [
    "${local.domain}"]
  acm_certificate_arn     = "${data.aws_acm_certificate.main.arn}"
  web_acl_id              = "${module.waf.id}"
  authorizer_path         = "${data.archive_file.authorizer.output_path}"
  authorizer_base64sha256 = "${data.archive_file.authorizer.output_base64sha256}"
}

data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "${path.module}/authorizer.zip"
  source_dir  = "${path.module}/authorizer"
}

### Endpoints
# TODO move route generation into module and automate
resource "aws_api_gateway_resource" "ping" {
  rest_api_id = "${module.api.rest_api_id}"
  parent_id   = "${module.api.root_resource_id}"
  path_part   = "ping"
}

resource "aws_api_gateway_resource" "ping_pong" {
  rest_api_id = "${module.api.rest_api_id}"
  parent_id   = "${aws_api_gateway_resource.ping.id}"
  path_part   = "pong"
}

module "ping" {
  source              = "../../public-api-endpoint"
  name                = "${local.name}"
  rest_api_id         = "${module.api.rest_api_id}"
  resource_id         = "${aws_api_gateway_resource.ping_pong.id}"
  http_method         = "GET"
  stage_name          = "${module.api.stage_name}"
  resource_path       = "${aws_api_gateway_resource.ping_pong.path}"
  lambda_path         = "${data.archive_file.ping_pong.output_path}"
  lambda_base64sha256 = "${data.archive_file.ping_pong.output_base64sha256}"
}

data "archive_file" "ping_pong" {
  type        = "zip"
  output_path = "${path.module}/ping.zip"
  source_dir  = "${path.module}/ping"
}


output "resource_path" {
  value = "${aws_api_gateway_resource.ping_pong.path}"
}

output "execution_arn" {
  value = "${module.api.execution_arn}"
}

