variable "name" {}

variable "engine" {
  default = "redis"
}

variable "engine_version" {
  default = "4.0.10"
}

variable "port" {
  default = 6379
}

variable "parameter_group_name" {
  default = "default.redis4.0"
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "node_type" {
  default = "cache.t2.small"
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

variable "automatic_failover_enabled" {
  default = "true"
}

variable "availability_zones" {
  type = "list"
}

variable "num_node_groups" {
  default = 1
}

variable "cluster_mode_enabled" {
  default = "false"
}

variable "at_rest_encryption_enabled" {
  default = "false"
}

variable "transit_encryption_enabled" {
  default = "false"
}

variable "security_group_ids" {
  type    = "list"
  default = []
}
