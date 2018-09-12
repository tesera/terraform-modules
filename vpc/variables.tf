variable "name" {
  type = "string"
}

variable "environment" {
  default = "unknown"
}

//variable "cost_id" {
//  default = "none"
//}

variable "az_count" {
  default = 2
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

# NAT vars
variable "nat_type" {
  default = "gateway"
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

variable "instance_type" {
  default = "t2.micro"
}
variable "volume_type" {
  default = "gp2"
}
variable "volume_size" {
  default = "8"
}


variable "key_name" {
  default = ""
}
