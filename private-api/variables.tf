variable "env" {
    type = "string"
}

variable "aws_account_id" {
    type    = "string"
}

variable "aws_region" {
    type    = "string"
    default = "ca-central-1"
}

variable "domain_name" {
    type = "string"
}

// waf
variable "defaultAction" {
    default = "ALLOW"
}
variable "ipWhiteListId" {}
variable "ipAdminListId" {}
variable "ipBlackListId" {}
