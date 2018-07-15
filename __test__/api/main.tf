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
  authorizer_path         = "${path.module}/authorizer" # TODO use path pattern from endpoint module
}


output "resource_path" {
  value = "${aws_api_gateway_resource.ping_pong.path}"
}

output "execution_arn" {
  value = "${module.api.execution_arn}"
}

