variable "name" {}

//variable "security_group_ids" {
//  type = "list"
//  default = []
//}
//variable "private_subnet_ids" {
//  type = "list"
//  default = []
//}

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
variable "handler" {
  default = "index.handler"
}
variable "runtime" {
  default = "nodejs8.10"
}
variable "memory_size" {
  default = 128
}
variable "tiemout" {
  default = 30
}

// NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS
variable "authorization" {
  default = "NONE"
}

// CUSTOM or COGNITO_USER_POOLS
variable "authorizer_id" {
  default = ""
}

// COGNITO_USER_POOLS
variable "authorization_scopes" {
  type = "list"
  default = []
}
