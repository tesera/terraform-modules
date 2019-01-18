module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  account_id = "${module.defaults.account_id}"
  name       = "${module.defaults.name}"
  tags       = "${module.defaults.tags}"
}
