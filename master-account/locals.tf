data "external" "groups" {
  program = [
    "node",
    "${path.module}/groups.js",
    "${join(",",var.sub_accounts)}",
    "${join(",",var.roles)}"]
}

module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
}

locals {
  account_id               = "${module.defaults.account_id}"
  aws_region               = "${module.defaults.aws_region}"
  name                     = "${module.defaults.name}"
  account_email_local_part = "${element(split("@", var.account_email),0)}"
  account_email_domain     = "${element(split("@", var.account_email),1)}"
  groups                   = "${data.external.groups.result}"

  minimum_password_length  = 32
}
