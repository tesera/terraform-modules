variable "account_alias" {
  type    = string
  default = ""
}

variable "groups" {
  type    = list(string)
  default = []
}

variable "email" {
  type = string
}

variable "pgp_key_path" {
  type = string
}

variable "account_email" {
  description = "Organization account email"
}

