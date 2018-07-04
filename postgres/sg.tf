data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "db" {
  name        = "${var.name}"
  description = "SecurityGroup for RDS"
  vpc_id      = "${var.vpc_id == "" ? data.aws_vpc.default.id : var.vpc_id}"

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
