variable "account_alias" {
  type    = "string"
  default = ""
}

variable "account_email" {
  type    = "string"
  default = ""
}

//variable "password_policy" {}

variable "users" {
  type    = "map"
  default = {}
}

variable "pgp_key_path" {
  type    = "string"
  default = ""
}
