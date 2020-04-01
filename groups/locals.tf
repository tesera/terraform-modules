data "aws_caller_identity" "current" {
}

data "null_data_source" "groups" {
  count = length(keys(var.sub_accounts))
  inputs = {
    groups = format("${keys(var.sub_accounts)[count.index]}-%s", join(",${keys(var.sub_accounts)[count.index]}-", var.roles))
  }
}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  groups       = split(",", join(",", data.null_data_source.groups.*.outputs.groups))
  sub_accounts = var.sub_accounts
}
