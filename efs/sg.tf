data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

resource "aws_security_group" "main" {
  name   = "${local.name}-${aws_efs_file_system.main.id}"
  vpc_id = data.aws_subnet.first.vpc_id

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name}-${aws_efs_file_system.main.id}"
    },
  )
}

