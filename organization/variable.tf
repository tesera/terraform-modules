variable "type" {
  type    = string
  default = "master"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "account_email" {
  description = "Organization account email"
}

variable "sub_accounts" {
  type = list(string)

  default = [
    "production",
    "staging",
    "testing",
    "development",
  ]
}

