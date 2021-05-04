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
  type = set(string)

  default = [
    "development",
    "qa",
    "production"
  ]
}

variable "create_master" {
  type    = bool
  default = false
}

variable "use_existing_organization" {
  type    = bool
  default = false
}

variable "organizational_unit_name" {
  type = string
}
