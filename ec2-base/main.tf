resource "aws_launch_configuration" "main" {
  name_prefix          = "${local.name}-"
  image_id             = local.image_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.main.name

  security_groups = [
    aws_security_group.main.id,
  ]

  user_data         = local.user_data
  ebs_optimized     = "false"
  enable_monitoring = "true"

  # Must be true in public subnets if assigning EIP in userdata
  associate_public_ip_address = var.subnet_public

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_autoscaling_group" "main" {
  name                      = "${local.name}-asg"
  max_size                  = local.max_size
  min_size                  = local.min_size
  desired_capacity          = local.desired_capacity
  health_check_grace_period = 30
  launch_configuration      = aws_launch_configuration.main.name

  vpc_zone_identifier = var.subnet_ids

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  tags = [module.defaults.tags_as_list_of_maps]
}

