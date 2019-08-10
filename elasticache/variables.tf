variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "engine" {
  default = "redis"
}

variable "engine_version" {
  default = "5.0"
}

variable "port" {
  default = 6379
}

variable "parameter_group_name" {
  default = ""
}

variable "vpc_id" {
}

variable "private_subnet_ids" {
  type = list(string)
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

variable "replica_count" {
  default = 0
}

variable "multi_az" {
  default = true
}

variable "node_count" {
  default = 1
}

variable "type" {
  default = "service"
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

