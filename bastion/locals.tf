data "aws_ami" "main" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2-ssh"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  account_id       = "${module.defaults.account_id}"
  aws_region       = "${module.defaults.aws_region}"
  name             = "${module.defaults.name}"
  tags             = "${module.defaults.tags}"
  image_id         = "${var.image_id != "" ? var.image_id : data.aws_ami.main.image_id}"
  max_size         = "1"
  min_size         = "1"
  desired_capacity = "1"
}
