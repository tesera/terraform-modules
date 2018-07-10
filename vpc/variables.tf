variable "name" {
  type = "string"
}

variable "environment" {
  default = "Unknown"
}

//variable "cost_id" {
//  default = "none"
//}

variable "az_count" {
  default = 2
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}
