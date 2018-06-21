variable "env" {
  type = "string"
}

variable "tenant" {
  type = "string"
}

variable "db_name" {
  type = "string"
}

variable "username" {
  type = "string"
}

variable "password" {
  type = "string"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}

variable "storage_type" {
  default = "gp2"
}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "9.5.10"
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "backup_window" {
  default = "06:00-07:00"
}

variable "parameter_group_name" {
  default = "default.postgres9.5"
}

variable "allocated_storage" {
  default = "200"
}

variable "backup_retention_period" {
  default = "7"
}

variable "multi_az" {
  default = true
}
