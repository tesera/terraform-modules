variable "account_email" {
  description = "Organization account email"
}

variable "sub_accounts" {
  type = "list"

  default = [
    "operations",
    "production",
    "staging",
    "testing",
    "development",
    "forensics",
  ]
}
