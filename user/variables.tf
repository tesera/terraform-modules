
variable "name" {
  type = "string"
}

variable "groups" {
  type = "list"
  default = []
}

variable "email" {
  type = "string"
}

variable "pgp_key_path" {
  type = "string"
}


variable "account_email" {
  description = "Organization account email"
}
