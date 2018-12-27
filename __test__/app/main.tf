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
  region  = "ca-central-1"
  profile     = "tesera"
  name        = "tesera-modules-test"
  domain_root = "tesera.com"
  domain      = "app.test.tesera.com"
}

provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${local.profile}"
  alias   = "edge"
}

# WAF
//module "waf" {
//  source        = "../../waf-owasp"
//  name          = "${local.name}"
//  defaultAction = "ALLOW"
//}

# APP
## DNS
data "aws_route53_zone" "main" {
  name = "${local.domain_root}."
}

resource "aws_route53_record" "main" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${local.domain}"
  type    = "A"

  alias = {
    name                   = "${module.app.domain_name}"
    zone_id                = "${module.app.hosted_zone_id}"
    evaluate_target_health = true
  }
}

## TLS
data "aws_acm_certificate" "main" {
  provider = "aws.edge"
  domain   = "${local.domain}"

  statuses = [
    "ISSUED",
  ]
}

## CDN
module "app" {
  source = "../../public-static-assets"
  name   = "${local.name}"

  aliases = [
    "${local.domain}",
  ]

  acm_certificate_arn = "${data.aws_acm_certificate.main.arn}"

  // web_acl_id          = "${module.waf.id}"
  #lambda_edge_content = "${replace(file("${path.module}/edge.js"), "{pkphash}", "${var.pkphash}")}"
}

resource "aws_s3_bucket_object" "index" {
  bucket                 = "${module.app.bucket}"
  key                    = "index.html"
  source                 = "${path.module}/index.html"
  content_type           = "text/html"
  server_side_encryption = "${module.app.server_side_encryption}"
}

resource "aws_s3_bucket_object" "404" {
  bucket                 = "${module.app.bucket}"
  key                    = "404.html"
  source                 = "${path.module}/404.html"
  content_type           = "text/html"
  server_side_encryption = "${module.app.server_side_encryption}"
}
