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
  default     = []
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

variable "cors_origins" {
  type    = list(string)
  default = ["*"]
}

# lambda@edge
variable "lambda" {
  type    = map(string)
  default = {}
}

variable "error_codes" {
  type    = map(string)
  default = {}
}

variable "logging_bucket" {
  type    = string
  default = ""
}

