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

data "template_file" "main-userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    REGION          = "${local.aws_region}"
    IAM_USER_GROUPS = "${var.iam_user_groups}"
    IAM_SUDO_GROUPS = "${var.iam_sudo_groups}"
  }
}

locals {
  account_id = "${var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id}"
  aws_region = "${data.aws_region.current.name}"
  image_id = "${var.image_id != "" ? var.image_id : data.aws_ami.main.image_id}"
  userdata = "${var.userdata != "" ? var.userdata : data.template_file.main-userdata.rendered}"
  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"
}
