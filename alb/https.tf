# HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  protocol          = "HTTPS"
  port              = "443"

  ssl_policy      = var.ssl_policy
  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}

# TODO allow multi certs - future feature
//resource "aws_lb_listener_certificate" "https" {
//  listener_arn = "${aws_lb_listener.https.arn}"
//  certificate_arn = ""
//}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.main.id

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  type      = "ingress"
  protocol  = "tcp"
  to_port   = "443"
  from_port = "443"
}

