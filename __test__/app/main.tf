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
resource "aws_waf_ipset" "empty" {
  name = "${local.name}-empty-ipset"
}

module "waf" {
  source = "../../waf"
  name   = "${local.name}"
  defaultAction = "ALLOW"

  ipAdminListId = "${aws_waf_ipset.empty.}"
  ipBlackListId = "${var.ipBlackListId}"
  ipWhiteListId = "${var.ipWhiteListId}"
}
