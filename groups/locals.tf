data "external" "groups" {
  program = [
    "node",
    "${path.module}/groups.js",
    join(",", keys(var.sub_accounts)),
    join(",", var.roles),
  ]
}

module "defaults" {
  source = "../defaults"
}

locals {
  account_id   = module.defaults.account_id
  groups       = data.external.groups.result
  sub_accounts = var.sub_accounts
}

