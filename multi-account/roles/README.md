# Roles
Setup common roles for modules

## Master Account
Setup bastion roles
```hcl-terraform
variable "sub_accounts" {
  type    = "map"
  default = {
    development = "000000000"
  }
}

module "roles" {
  source       = "git@github.com:willfarrell/terraform-account-modules//roles?ref=v0.1.4"
  type         = "master"
  sub_accounts = var.sub_accounts
}
```

## Sub-Account
Setup admin and dev roles
```hcl-terraform
data "terraform_remote_state" "master" {
  backend = "s3"

  config = {
    bucket  = "terraform-state-*******"
    key     = "master/account/terraform.tfstate"
    region  = "us-east-1"
    profile = "*******"
  }
}

module "roles" {
  source       = "git@github.com:willfarrell/terraform-account-modules//roles?ref=v0.1.4"
  type         = "environment"
  master_account_id = data.terraform_remote_state.master.outputs.id 
}
```


## TODO
- [ ] have use pass in policy
