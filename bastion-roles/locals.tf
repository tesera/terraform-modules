module "defaults" {
  source = "../defaults"
}

locals {
  account_id = "${module.defaults.account_id}"
  sub_accounts = "${var.sub_accounts}"
}
