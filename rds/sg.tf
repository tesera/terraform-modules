resource "aws_security_group" "main" {
  name   = "${local.identifier}-security-group"
  vpc_id = var.vpc_id

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      "Name"        = local.identifier
      "Description" = "SecurityGroup for ${local.identifier}"
    }
  )
}

resource "aws_security_group_rule" "rds_access" {
  count                    = length(var.security_group_ids)
  security_group_id        = aws_security_group.main.id
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ids[count.index]
}

