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

  dynamic "tag" {
    for_each = local.tags
    content {
      key   = tag.key
      value = tag.value

      propagate_at_launch = true
    }
  }
}

