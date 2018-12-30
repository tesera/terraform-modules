module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
}

locals {
  account_id = "${module.defaults.account_id}"
  region     = "${module.defaults.region}"
  name       = "${module.defaults.name}"
}
