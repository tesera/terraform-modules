//variable "aws_account_id" {
//  type        = "string"
//  description = "AWS Account ID"
//}

// Suggested:
// ${env}-${subdomain}-${domain}-${tld}
variable "name" {
  type        = "string"
  description = "AWS S3 Bucket. {env}-{name}"
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

variable "lambda_edge_content" {
  type        = "string"
  default     = "null"
  description = "function content to be used for edge lambda"
}
