variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "hash_key" {
}

# variable "range_key" {
#   default = ""
# }

variable "ttl_enabled" {
  default = false
}

variable "encryption_enabled" {
  default = true
}

variable "min_read_capacity" {
  default = "100"
}

variable "max_read_capacity" {
  default = "10000"
}

variable "min_write_capacity" {
  default = "100"
}

variable "max_write_capacity" {
  default = "10000"
}

variable "read_target_value" {
  default = "50"
}

variable "write_target_value" {
  default = "50"
}

