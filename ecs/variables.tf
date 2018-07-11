variable "name" {}
variable "account_id" {
  default = ""
}
variable "vpc_id" {}
variable "private_subnet_ids" {
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

