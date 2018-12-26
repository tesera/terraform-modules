module "defaults" {
  source = "../defaults"
}

locals {
  account_id              = "${module.defaults.account_id}"
  aws_region              = "${module.defaults.aws_region}"
  account_alias           = "${var.account_alias != "" ? var.account_alias : module.defaults.account_id}"
  minimum_password_length = 32
}
