variable "vpc_id" {
  description = "aws_vpc.main.id"
}

variable "name" {
  description = "application anme"
}

variable "cidr_block" {}

variable "availability_zone" {
  description = "should include region"
}

variable "route_table_id" {}
