module "ec2-base" {
  source                 = "../ec2-base"
  name                   = local.name
  default_tags           = local.tags
  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids
  subnet_public          = var.subnet_public
  image_id               = var.image_id != "" ? var.image_id : data.aws_ami.main.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = var.user_data
  volume_type            = var.volume_type
  volume_size            = var.volume_size
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  efs_ids                = var.efs_ids
  efs_security_group_ids = var.efs_security_group_ids
}

