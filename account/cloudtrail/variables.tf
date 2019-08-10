variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "logging_bucket" {
  type    = string
  default = ""
}

