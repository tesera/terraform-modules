
resource "aws_autoscaling_attachment" "ecs" {
  autoscaling_group_name = "${var.autoscaling_group_name}"
  alb_target_group_arn   = "${aws_lb_target_group.main.arn}"
}

resource "aws_security_group_rule" "ecs_access" {
  security_group_id        = "${var.security_group_id}"
  type                     = "ingress"
  from_port                = "${var.port}"
  to_port                  = "${var.port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.main.id}"
}
