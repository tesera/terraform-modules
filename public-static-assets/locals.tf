module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  region        = "${module.defaults.region}"
  tags          = "${module.defaults.tags}"
  name          = "${module.defaults.name}"
  sse_algorithm = "AES256"
}
