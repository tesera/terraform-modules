variable "sub_accounts" {
  type = map(string)

  default = {
    operations  = ""
    production  = ""
    staging     = ""
    testing     = ""
    development = ""
  }
}

