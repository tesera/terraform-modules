variable "name" {
  type        = "string"
  description = "AWS S3 Bucket. {env}-{name}"
}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "aliases" {
  type        = "list"
  description = "Cloudfront Aliases"
}

variable "acm_certificate_arn" {
  "type" = "string"
}

variable "web_acl_id" {
  type        = "string"
  default     = ""
  description = "WAF ACL ID"
}

variable "authorizer_dir" {
  default = ""
}

variable "lambda_dir" {}
variable "lambda_config_path" {}

variable "handler" {
  default = "index.handler"
}

variable "runtime" {
  default = "nodejs8.10"
}

variable "memory_size" {
  default = 128
}

variable "timeout" {
  default = 30
}

variable "xray" {
  type    = "string"
  default = "false"
}

//variable "authorizer_client_id" {}
//variable "authorizer_client_secret" {}

variable "logging_bucket" {
  type = "string"
  default = ""
}
