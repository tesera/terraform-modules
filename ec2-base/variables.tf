variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
}

variable "subnet_ids" {
  type = list(string)
}

variable "subnet_public" {
  default = "false"
}

variable "image_id" {
  default = ""
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = ""
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

variable "efs_ids" {
  type    = list(string)
  default = []
}

variable "efs_security_group_ids" {
  type    = list(string)
  default = []
}

variable "iam_service" {
  type    = string
  default = "ec2"
}

