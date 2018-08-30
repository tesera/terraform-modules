variable "name" {}

variable "vpc_id" {}

variable "db_name" {
  type    = "string"
  default = ""
}

variable "username" {
  type    = "string"
  default = "admin"
}

variable "password" {
  type = "string"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "storage_type" {
  default = "gp2"
}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "10.3"
}

variable "instance_class" {
  default = "db.t2.small"
}

variable "backup_window" {
  default = "06:00-07:00"
}

variable "parameter_group_name" {
  default = "default.postgres10"
}

variable "allocated_storage" {
  default = "20"
}

variable "backup_retention_period" {
  default = "7"
}

variable "multi_az" {
  default = true
}

variable "replica_count" {
  default = "0"
}

variable "publicly_accessible" {
  default = "false"
}
