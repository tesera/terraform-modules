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


variable "authorizer_path" {
    default = ""
}
variable "authorizer_base64sha256" {
    default = ""
}
//variable "authorizer_client_id" {}
//variable "authorizer_client_secret" {}
