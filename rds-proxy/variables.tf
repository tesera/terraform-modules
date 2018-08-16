variable "name" {}
variable "account_id" {
  default = ""
}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = "list"
}

variable "image_id" {
  default = ""
}
variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {}
variable "volume_type" {
  default = "gp2"
}
variable "volume_size" {
  default = "8"
}

variable "iam_user_groups" {
  default = ""
}

variable "iam_sudo_groups" {
  default = ""
}

variable "bastion_security_group_id" {
  default = ""
}

variable "rds_name" {
  default = "database"
}

variable "rds_port" {
  default = "5432"
}

variable "rds_health_port" {
  default = "9200"
}

variable "rds_endpoint" {}
