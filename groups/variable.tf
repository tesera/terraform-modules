variable "type" {
  type = string
}

variable "roles" {
  type    = list(string)
  default = ["admin", "developer"]
}

variable "sub_accounts" {
  type = map(string)

  default = {
    production  = ""
    staging     = ""
    testing     = ""
    development = ""
  }
}

variable "role_mfa" {
  type    = string
  default = "false"
}

