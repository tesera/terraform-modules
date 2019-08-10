variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "aliases" {
  type = list(string)
}

variable "redirect" {
}

variable "acm_certificate_arn" {
  type = string
}

variable "logging_bucket" {
  type    = string
  default = ""
}

