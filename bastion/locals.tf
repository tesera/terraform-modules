data "aws_ami" "main" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2-ssh",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  owners = [
    var.ami_account_id
  ]
}

module "defaults" {
  source = "../defaults"
  name   = "${var.name}-bastion"
  tags   = var.default_tags
}

locals {
  account_id       = module.defaults.account_id
  region           = module.defaults.region
  name             = module.defaults.name
  tags             = module.defaults.tags
  image_id         = var.image_id != "" ? var.image_id : data.aws_ami.main.image_id
  max_size         = "1"
  min_size         = "1"
  desired_capacity = "1"
  assume_role_arn  = var.assume_role_arn == "" ? aws_iam_role.ssh[0].arn : var.assume_role_arn
}

