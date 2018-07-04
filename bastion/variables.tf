variable "name" {}
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

