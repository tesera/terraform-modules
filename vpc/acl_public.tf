resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  #subnet_ids = ["${aws_subnet.public.*.id}"]
  subnet_ids = concat(aws_subnet.public.*.id, aws_subnet.private.*.id)

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-public"
    }
  )
}

# TODO move external to ELB
# HTTP External Requests
resource "aws_network_acl_rule" "ingress_http_public_ipv4" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4080
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "ingress_http_public_ipv6" {
  network_acl_id  = aws_network_acl.public.id
  rule_number     = 6080
  egress          = false
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 80
  to_port         = 80
}

# HTTPS External Requests
resource "aws_network_acl_rule" "ingress_https_public_ipv4" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4443
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ingress_https_public_ipv6" {
  network_acl_id  = aws_network_acl.public.id
  rule_number     = 6443
  egress          = false
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 443
  to_port         = 443
}

# Ephemeral Ports for External Requests
resource "aws_network_acl_rule" "egress_ephemeral_public_ipv4" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4999
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "egress_ephemeral_public_ipv6" {
  network_acl_id  = aws_network_acl.public.id
  rule_number     = 6999
  egress          = true
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 1024
  to_port         = 65535
}

# HTTP Internal Requests
resource "aws_network_acl_rule" "egress_http_public_ipv4" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4080
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "egress_http_public_ipv6" {
  network_acl_id  = aws_network_acl.public.id
  rule_number     = 6080
  egress          = true
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 80
  to_port         = 80
}

# HTTPS Internal Requests
resource "aws_network_acl_rule" "egress_https_public_ipv4" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4443
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "egress_https_public_ipv6" {
  network_acl_id  = aws_network_acl.public.id
  rule_number     = 6443
  egress          = true
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 443
  to_port         = 443
}

# Ephemeral Ports for Internal Requests
resource "aws_network_acl_rule" "ingress_ephemeral_public_ipv4" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4999
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "ingress_ephemeral_public_ipv6" {
  network_acl_id  = aws_network_acl.public.id
  rule_number     = 6999
  egress          = false
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 1024
  to_port         = 65535
}

# ICMP
//resource "aws_network_acl_rule" "ingress_icmp" {
//  network_acl_id = "${aws_network_acl.main.id}"
//  rule_number    = 103
//  egress         = false
//  protocol       = "icmp"
//  rule_action    = "allow"
//  cidr_block     = "0.0.0.0/0"
//  icmp_type      = -1
//  icmp_code      = -1
//}
//
//resource "aws_network_acl_rule" "egress_icmp" {
//  network_acl_id = "${aws_network_acl.main.id}"
//  rule_number    = 103
//  egress         = true
//  protocol       = "icmp"
//  rule_action    = "allow"
//  cidr_block     = "0.0.0.0/0"
//  icmp_type      = -1
//  icmp_code      = -1
//}
