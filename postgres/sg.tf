resource "aws_security_group" "db" {
  name = "${var.name}"

  description = "SecurityGroup for RDS"

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
