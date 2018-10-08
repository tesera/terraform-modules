variable "name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "account_id" {
  default = ""
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "subnet_public" {
  default = "false"
}

variable "image_id" {
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = ""
}

variable "banner" {
  default = "AWS EC2"
}

variable "user_data" {
  default = ""
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "8"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "1"
}

variable "desired_capacity" {
  default = "1"
}

variable "iam_user_groups" {
  default = ""
}

variable "iam_sudo_groups" {
  default = ""
}

variable "iam_local_groups" {
  default = ""
}

variable "bastion_security_group_id" {
  default = ""
}
