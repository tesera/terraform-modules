resource "aws_security_group" "main" {
  name   = "${var.name}"
  vpc_id = "${var.vpc_id}"

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group_rule" "efs_access" {
  count                    = "${length(var.efs_security_group_ids)}"
  security_group_id        = "${element(var.efs_security_group_ids,count.index)}"
  type                     = "ingress"
  from_port                = "2049"
  to_port                  = "2049"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.main.id}"
}
