data "aws_ami" "main" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn2-ami-ecs-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  owners = [var.ami_account_id]
}

module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  account_id       = module.defaults.account_id
  region           = module.defaults.region
  name             = "${module.defaults.name}-ecs"
  tags             = module.defaults.tags
  image_id         = var.image_id != "" ? var.image_id : data.aws_ami.main.image_id
  instance_type    = var.instance_type
  max_size         = var.max_size
  min_size         = var.min_size
  desired_capacity = var.desired_capacity
}

