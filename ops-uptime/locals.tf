module "defaults" {
  source = "../defaults"
  name   = "${var.name}-uptime"
  tags   = "${var.default_tags}"
}

locals {
  name    = "${module.defaults.name}"
  tags    = "${module.defaults.tags}"
  region  = "${module.defaults.region}"
  profile = "${module.defaults.profile}"
}
