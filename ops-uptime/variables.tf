variable "name" {
  type = "string"
}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "fqdn" {
  type        = "string"
  description = "fully qualified domain name"
}

variable "resource_path" {
  type    = "string"
  default = "/"
}

variable "failure_threshold" {
  type    = "string"
  default = "3"
}

variable "request_interval" {
  type    = "string"
  default = "30"
}

variable "regions" {
  type    = "list"
  default = ["us-east-1", "us-west-1", "us-west-2"]
}

variable "sns_subscribe_primary" {
  type        = "string"
  description = "email address for notifications"
}
