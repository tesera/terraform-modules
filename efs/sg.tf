data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

resource "aws_security_group" "main" {
  name   = "${var.name}"
  vpc_id = "${data.aws_subnet.selected.vpc_id}"

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

# resource "aws_security_group_rule" "efs_access" {
#   count                    = "${length(var.security_group_ids)}"
#   security_group_id        = "${aws_security_group.main.id}"
#   type                     = "ingress"
#   from_port                = "2049"
#   to_port                  = "2049"
#   protocol                 = "tcp"
#   source_security_group_id = "${var.security_group_ids[count.index]}"
# }

