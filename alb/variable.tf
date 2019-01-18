variable "name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "vpc_id" {
  type = "string"
}

variable "private_subnet_ids" {
  type    = "list"
  default = []
}

variable "waf_acl_id" {
  type    = "string"
  default = ""
}

variable "https_only" {
  default = true
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
# ELBSecurityPolicy-2016-08 => Most accessible, >=TLS 1.0
# ELBSecurityPolicy-TLS-1-1-2017-01 => Most accessible, >=TLS 1.1
# ELBSecurityPolicy-TLS-1-2-2017-01 => Most secure, >=TLS 1.2, !SHA
variable "ssl_policy" {
  type    = "string"
  default = "ELBSecurityPolicy-TLS-1-1-2017-01"
}

variable "certificate_arn" {
  type = "string"
}

# ECS
variable "port" {
  type    = "string"
  default = 80
}

variable "autoscaling_group_name" {
  type = "string"
}

variable "security_group_id" {
  type = "string"
}
