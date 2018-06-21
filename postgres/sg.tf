resource "aws_security_group" "db" {
  name = "${local.db_id}"

  description = "SecurityGroup for RDS"

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
