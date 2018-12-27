module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  #tags   = "${var.default_tags}"
}

locals {
  region = "${module.defaults.region}"
  name       = "${replace(var.name, "/[_]/", "-")}"
  stage_name = "api"

  authorizer_path = "${var.authorizer_dir != "" ? var.authorizer_dir : "${path.module}/authorizer"}"
}
