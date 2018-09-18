resource "aws_security_group" "main" {
  name        = "${var.name}-security-group"
  description = "SecurityGroup for RDS"
  vpc_id      = "${var.vpc_id}"

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  count                    = "${var.bastion_security_group_id != "" ? 1 : 0}"
  security_group_id        = "${aws_security_group.main.id}"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${var.bastion_security_group_id}"
}
