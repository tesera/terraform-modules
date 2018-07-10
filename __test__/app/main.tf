locals {
  aws_region = "ca-central-1"
  profile    = "tesera"
  name       = "tesera-modules-test"
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
  source = "../../waf-owasp"
  name   = "${local.name}"
  defaultAction = "ALLOW"
}

# APP

module "app" {
  source = "../../public-static-assets"
  name = "${local.name}"
  
}
