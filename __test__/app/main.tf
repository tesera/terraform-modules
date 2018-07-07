locals {
  aws_region = "ca-central-1"
  profile    = "tesera"
  name       = "tesera-modules-test"
  domain     = "test.tesera.com"
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
  source        = "../../waf"
  name          = "${local.name}"
  defaultAction = "ALLOW"
}

# APP

data "aws_acm_certificate" "main" {
  provider = "aws.edge"
  domain   = "${local.domain}"
  statuses = [
    "ISSUED"]
}

module "app" {
  source              = "../../public-statis-assets"
  name                = "${local.name}"

  aliases             = [
    "${local.domain}"]
  acm_certificate_arn = "${data.aws_acm_certificate.main.arn}"
  web_acl_id          = "${module.waf.id}"
  #lambda_edge_content = "${replace(file("${path.module}/edge.js"), "{pkphash}", "${var.pkphash}")}"
}

resource "aws_s3_bucket_object" "index" {
  bucket                 = "${module.app.bucket}"
  key                    = "index.html"
  source                 = "index.html"
  server_side_encryption = "${module.app.server_side_encryption}"
}
