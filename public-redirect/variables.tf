variable "name" {}
variable "aliases" {
  type = "list"
}
variable "redirect" {}

variable "acm_certificate_arn" {
  "type" = "string"
}
