variable "name" {}

variable "security_group_ids" {
  type = "list"
}
variable "private_subnet_ids" {
  type = "list"
}

variable "rest_api_id" {}
variable "resource_id" {}
variable "stage_name" {}
#variable "execution_arn" {}
variable "http_method" {
  default = "GET"
}
variable "resource_path" {}

variable "policy" {
  default = ""
}
variable "source_dir" {
  default = ""
}
//variable "lambda_path" {
//  default = ""
//}
//variable "lambda_base64sha256" {
//  default = ""
//}
