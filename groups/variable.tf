

//
variable "roles" {
  type = "list"
  default = ["admin"]
}

//variable "sub_accounts" {
//  type = "list"
//  default = [
//    "operations",
//    "production",
//    "staging",
//    "testing",
//    "development",
//    "forensics"
//  ]
//}

variable "sub_accounts" {
  type = "map"
  default = {
    operations = ""
    production = ""
    staging = ""
    testing = ""
    development = ""
  }
}

variable "role_mfa" {
  type = "string"
  default = "false"
}
