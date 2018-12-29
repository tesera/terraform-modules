// Suggested:
// ${env}-${subdomain}-${domain}-${tld}
variable "name" {
  type        = "string"
  description = "AWS S3 Bucket. {env}-{name}"
}

variable "default_tags" {
  type = "map"
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

variable "lambda_viewer_request" {
  type        = "string"
  default     = ""
  description = "function content to be used for edge lambda"
}

variable "lambda_viewer_response" {
  type        = "string"
  default     = ""
  description = "function content to be used for edge lambda"
}
