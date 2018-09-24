
module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
}

locals {
  account_id   = "${module.defaults.account_id}"
  aws_region   = "${module.defaults.aws_region}"
  name         = "${module.defaults.name}"
  subaccounts = [
    "operations",
    "production",
    "staging",
    "testing",
    "development",
    "forensics"
  ]
}
