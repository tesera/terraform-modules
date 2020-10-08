resource "aws_instance" "mike_linux" {
  ami                  = var.image_id
  instance_type        = "r5.4xlarge"
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.iam_ssh.id
  user_data = templatefile("${path.module}/user_data.sh", {
    IAM_AUTHORIZED_GROUPS = var.iam_user_groups
    SUDOERS_GROUPS        = var.iam_sudo_groups
    ASSUMEROLE            = local.assume_role_arn
    LOCAL_GROUPS          = "docker"
  })

  vpc_security_group_ids = [
    aws_security_group.iam_ssh.id,
  ]

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  ebs_optimized = true

  tags = {
    Name = local.name
  }
}
