variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "account_id" {
  default = ""
}

variable "vpc_id" {
}

variable "subnet_id" {
}

variable "image_id" {
  default = ""
}

variable "instance_type" {
  default = "t3.micro"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "100"
}

variable "iam_user_groups" {
  default = ""
}

variable "iam_sudo_groups" {
  default = ""
}

variable "assume_role_arn" {
  default = ""
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "cidr_blocks" {
  type    = list(string)
  default = []
}
