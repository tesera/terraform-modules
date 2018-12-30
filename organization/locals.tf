module "defaults" {
  source = "../defaults"
}

locals {
  account_id               = "${module.defaults.account_id}"
  region                   = "${module.defaults.region}"
  account_email_local_part = "${element(split("@", var.account_email),0)}"
  account_email_domain     = "${element(split("@", var.account_email),1)}"
}
