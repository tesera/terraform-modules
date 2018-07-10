data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "main" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

locals {
  account_id = "${var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id}"
  aws_region = "${data.aws_region.current.name}"
  image_id = "${var.image_id != "" ? var.image_id : data.aws_ami.main.image_id}"
  max_size = "${var.min_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"
}
