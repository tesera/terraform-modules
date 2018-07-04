data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "main" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  account_id = "${var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id}"
  aws_region = "${data.aws_region.current.name}"
  image_id = "${var.image_id != "" ? var.image_id : data.aws_ami.main.image_id}"
  max_size = "1"
  min_size = "1"
  desired_capacity = "1"
}
