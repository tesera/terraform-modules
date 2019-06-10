variable "name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "aliases" {
  type = "list"
}

variable "redirect" {}

variable "acm_certificate_arn" {
  "type" = "string"
}

variable "logging_bucket" {
  type = "string"
  default = ""
}
