resource "aws_default_network_acl" "main" {
  default_network_acl_id = "${aws_vpc.main.default_network_acl_id}"

  tags                   = "${merge(local.tags, map(
    "Name", "${local.name}"
  ))}"
}

// Has dep issue
//resource "aws_network_acl" "main" {
//  depends_on = [
//    "aws_subnet.public",
//    "aws_subnet.private"]
//
//  vpc_id     = "${aws_vpc.main.id}"
//  subnet_ids = [
//    "${concat(list(aws_subnet.public.id),aws_subnet.private.*.id)}"]
//
//  tags       = "${merge(local.tags, map(
//    "Name", "${local.name}"
//  ))}"
//}

# HTTP - TODO move to ELB module
resource "aws_network_acl_rule" "ingress_http" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "egress_http" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# HTTPS
resource "aws_network_acl_rule" "ingress_https" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 101
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "egress_https" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 101
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# ICMP
resource "aws_network_acl_rule" "ingress_icmp" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 103
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = -1
  icmp_code      = -1
}

resource "aws_network_acl_rule" "egress_icmp" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 103
  egress         = true
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = -1
  icmp_code      = -1
}

# DNS via UDP
# TODO remove when DNS via DoH or DNS over TLS is support accross internal application
resource "aws_network_acl_rule" "ingress_dns" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 153
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "egress_dns" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 153
  egress         = true
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "ingress_dns_tls" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 853
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 853
  to_port        = 853
}

resource "aws_network_acl_rule" "egress_dns_tls" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 853
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 853
  to_port        = 853
}

# Ephemeral Ports
resource "aws_network_acl_rule" "ingress_ephemeral" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 888
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "egress_ephemeral" {
  network_acl_id = "${aws_default_network_acl.main.id}"
  rule_number    = 888
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}



