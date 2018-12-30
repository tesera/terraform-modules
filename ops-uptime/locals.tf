module "defaults" {
  source = "../defaults"
  name   = "${var.name}-uptime"
  #tags   = "${var.default_tags}"
}

locals {
  region  = "${module.defaults.region}"
  profile = "${module.defaults.profile}"
}
