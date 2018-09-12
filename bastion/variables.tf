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



variable "key_name" {
  default = ""
}
