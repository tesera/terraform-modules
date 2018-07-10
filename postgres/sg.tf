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
