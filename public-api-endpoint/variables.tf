variable "name" {}

variable "rest_api_id" {}
variable "resource_id" {}
variable "stage_name" {}
#variable "execution_arn" {}
variable "http_method" {
  default = "GET"
}
variable "resource_path" {}

variable "lambda_policy" {
  default = ""
}
variable "lambda_path" {
  default = ""
}
variable "lambda_base64sha256" {
  default = ""
}
