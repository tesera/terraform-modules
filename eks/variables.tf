variable "name" {}
variable "default_tags" {
  type = "map"
  default = {}
}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = "list"
}

# EC2
variable "image_id" {
  default = ""
}
variable "instance_type" {
  default = "t2.micro"
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
  default = "2"
}

variable "desired_capacity" {
  default = "2"
}

# ssh
variable "iam_user_groups" {
  default = ""
}

variable "iam_sudo_groups" {
  default = ""
}

variable "bastion_security_group_id" {
  default = ""
}

# Debug
variable "key_name" {
  default = ""
}
