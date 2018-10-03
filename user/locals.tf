module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
}

locals {
  account_id               = "${module.defaults.account_id}"
  aws_region               = "${module.defaults.aws_region}"
  name                     = "${module.defaults.name}"

  minimum_password_length  = 32
}
