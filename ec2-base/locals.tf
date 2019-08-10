data "aws_ami" "main" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  owners = ["137112412989"]
}

data "template_file" "userdata" {
  template = file("${path.module}/user_data.sh")

  vars = {
    EFS_IDS   = join(",", var.efs_ids)
    USER_DATA = var.user_data
  }
}

module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  account_id       = module.defaults.account_id
  region           = module.defaults.region
  name             = module.defaults.name
  tags             = module.defaults.tags
  image_id         = var.image_id != "" ? var.image_id : data.aws_ami.main.image_id
  user_data        = data.template_file.userdata.rendered
  max_size         = var.max_size
  min_size         = var.min_size
  desired_capacity = var.desired_capacity
}

