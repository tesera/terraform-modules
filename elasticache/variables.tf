variable "name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "engine" {
  default = "redis"
}

variable "version" {
  default = "4.0.10"
}

variable "port" {
  default = 6379
}

variable "parameter_group_name" {
  default = "default.redis4.0"
}

variable "vpc_id" {}

variable "private_subnet_ids" {
  type = "list"
}

variable "instance_type" {
  default = "cache.t2.micro"
}

variable "maintenance_window" {
  default = "sun:05:00-sun:09:00"
}

variable "apply_immediately" {
  default = "false"
}

variable "read_replicas" {
  default = 0
}

variable "multi_az" {
  default = "true"
}

variable "num_node_groups" {
  default = 1
}

variable "type" {
  default = "standalone"
}

variable "security_group_ids" {
  type    = "list"
  default = []
}
