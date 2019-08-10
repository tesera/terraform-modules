// Suggested:
// ${env}-${subdomain}-${domain}-${tld}
variable "name" {
  type        = string
  description = "AWS S3 Bucket. {env}-{name}"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "aliases" {
  type        = list(string)
  description = "Cloudfront Aliases"
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "web_acl_id" {
  type        = string
  default     = ""
  description = "WAF ACL ID"
}

# lambda@edge
variable "lambda_viewer_request_default" {
  default = false
}

variable "lambda_viewer_request" {
  type    = string
  default = ""
}

variable "lambda_origin_request_default" {
  default = false
}

variable "lambda_origin_request" {
  type    = string
  default = ""
}

variable "lambda_viewer_response_default" {
  default = false
}

variable "lambda_viewer_response" {
  type    = string
  default = ""
}

variable "lambda_origin_response_default" {
  default = false
}

variable "lambda_origin_response" {
  type    = string
  default = ""
}

variable "logging_bucket" {
  type    = string
  default = ""
}

