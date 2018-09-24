//variable "aws_account_name" {
//  type = "string"
//  description = "name of the account. ie root, operations, production"
//}

//variable "aws_parent_account_id" {
//  type = "string"
//  default = ""
//  description = "For provider has allowed_account_ids"
//}

//variable "aws_account_id" {
//  type = "string"
//  description = "For provider has allowed_account_ids"
//}
//
//variable "aws_profile" {
//  default = "default"
//}
//
//variable "aws_default_region" {
//  default = "us-east-1"
//}

variable "account_email" {
  description = "Organization account email"
}


//variable "administrator_default_arn" {
//  default = "arn:aws:iam::aws:policy/AdministratorAccess"
//}
//
//variable "developer_default_arn" {
//  default = "arn:aws:iam::aws:policy/PowerUserAccess"
//}
//
//variable "billing_default_arn" {
//  default = "arn:aws:iam::aws:policy/job-function/Billing"
//}
