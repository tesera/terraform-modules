variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
}

variable "network_acl_id" {
}

variable "acl_rule_number" {
  default = 22
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "account_id" {
  default = ""
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
  default = "8"
}

variable "iam_user_groups" {
  default = ""
}

variable "iam_sudo_groups" {
  default = ""
}

variable "assume_role_arn" {
}

