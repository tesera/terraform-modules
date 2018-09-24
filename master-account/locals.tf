module "locals" {
  source = "../defaults"
}

locals {
  account_email_local_part = "${element(split("@", var.account_email),0)}"
  account_email_domain     = "${element(split("@", var.account_email),1)}"
  subaccounts              = [
    "operations",
    "production",
    "staging",
    "testing",
    "development",
    "forensics"
  ]
}
