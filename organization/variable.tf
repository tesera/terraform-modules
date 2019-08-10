variable "account_email" {
  description = "Organization account email"
}

variable "sub_accounts" {
  type = list(string)

  default = [
    "operations",
    "production",
    "staging",
    "testing",
    "development",
    "forensics",
  ]
}

