resource "aws_security_group" "iam_ssh" {
  name   = "${local.name}-security-group"
  vpc_id = var.vpc_id

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "${local.name}-security-group"
    "Description" = "SecurityGroup for ${local.name} instance"
  }

}

resource "aws_security_group_rule" "ssh_access_security_groups" {
  count                    = length(var.security_group_ids)
  security_group_id        = aws_security_group.iam_ssh.id
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ids[count.index]
}

resource "aws_security_group_rule" "ssh_access_cidr" {
  count             = length(var.cidr_blocks) > 0 ? 1 : 0
  security_group_id = aws_security_group.iam_ssh.id
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
}
