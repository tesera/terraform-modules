variable "name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "logging_bucket" {
  type = "string"
  default = ""
}
