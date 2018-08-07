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

variable "lambda_dir" {}
variable "lambda_config_path" {}

variable "runtime" {
    default = "nodejs8.10"
}
variable "memory_size" {
    default = 128
}
variable "tiemout" {
    default = 30
}
//variable "authorizer_client_id" {}
//variable "authorizer_client_secret" {}
