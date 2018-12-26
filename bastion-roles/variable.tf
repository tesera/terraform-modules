
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
