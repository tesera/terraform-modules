module "defaults" {
  source = "../../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  account_id = "${module.defaults.account_id}"
  name       = "${module.defaults.name}-cloudtrail"
  tags       = "${module.defaults.tags}"

  logging_bucket = "${var.logging_bucket != "" ? var.logging_bucket : "${module.defaults.name}-${terraform.workspace}-edge-logs" }}"
}
