data "aws_ami" "main" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }
}

module "defaults" {
  source = "../defaults"
  name   = "${var.name}-proxy"
  tags   = "${var.default_tags}"
}

locals {
  region           = "${module.defaults.region}"
  tags             = "${module.defaults.tags}"
  name             = "${module.defaults.name}"
  account_id       = "${module.defaults.account_id}"
  image_id         = "${var.image_id != "" ? var.image_id : data.aws_ami.main.image_id}"
  max_size         = "1"
  min_size         = "1"
  desired_capacity = "1"
}
