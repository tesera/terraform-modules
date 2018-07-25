locals {
  aws_region = "us-east-1"
  name = "${replace(var.name, "/[_]/", "-")}"
}
