variable "name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "subnet_id" {}

variable "kms_key_id" {
  default = ""
}

variable "performance_mode" {
  default = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  default = "0"
}

variable "throughput_mode" {
  default = "bursting"
}

variable "ip_address" {
  default = ""
}
