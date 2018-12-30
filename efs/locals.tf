module "defaults" {
  source = "../defaults"
  name   = "${var.name}-${var.performance_mode}"
  tags   = "${var.default_tags}"
}

locals {
  name = "${module.defaults.name}"
  tags = "${module.defaults.tags}"
}
