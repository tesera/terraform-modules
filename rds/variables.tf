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

variable "engine_mode" {
  default = "provisioned"
}

variable "instance_class" {
  default = "db.t2.micro"
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

variable "security_group_ids" {
  type    = "list"
  default = []
}

variable "cpu_alarm_threshold" {
  default = "80"
}

variable "cpu_alarm_evaluation_periods" {
  default = "3"
}

variable "swap_alarm_threshold" {
  default = "0"
}

variable "free_space_alarm_threshold" {
  default = 1073741824 # 1G
}

variable "read_latency_alarm_threshold" {
  default = "0.2" # 200ms
}

variable "write_latency_alarm_threshold" {
  default = "0.2" # 200ms
}

variable "ssh_identity_file" {
  default = ""
}

variable "ssh_username" {
  default = "ec2-user"
}

variable "bastion_ip" {
  default = ""
}

variable "init_scripts_folder" {
  default = ""
}

variable "type" {
  default = "service"
}

variable "apply_immediately" {
  default = "false"
}

variable "skip_final_snapshot" {
  default = "false"
}

variable "instance_count" {
  default = "2"
}

variable "cluster_engine" {
  default = "aurora-postgresql"
}

variable "iam_database_authentication_enabled" {
  default = "false"
}
