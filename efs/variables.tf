variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {
  type = list(string)
}

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

