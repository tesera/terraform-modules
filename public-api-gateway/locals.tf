module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  region     = "${module.defaults.region}"
  tags       = "${module.defaults.tags}"
  name       = "${module.defaults.name}"
  stage_name = "api"

  authorizer_path = "${var.authorizer_dir != "" ? var.authorizer_dir : "${path.module}/authorizer"}"

  logging_bucket = "${var.logging_bucket != "" ? var.logging_bucket : "${module.defaults.name}-${terraform.workspace}-edge-logs" }"
}
