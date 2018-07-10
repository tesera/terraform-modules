variable "name" {
  type = "string"
}

variable "az_count" {
  default = 2
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}
