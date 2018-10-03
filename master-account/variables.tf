
variable "name" {
  type = "string"
}

//
variable "roles" {
  type = "list"
  default = ["admin","developer"]
}

// {username:[role,role]}
//variable "users" {
//  type = "map"
//  default = {}
//}

//variable "pgp_key_path" {
//  type = "string"
//}


variable "account_email" {
  description = "Organization account email"
}

variable "sub_accounts" {
  type = "list"
  default = [
    "operations",
    "production",
    "staging",
    "testing",
    "development",
    "forensics"
  ]
}
