resource "aws_eip" "main" {
  vpc = "true"

  tags = "${merge(local.tags, map(
    "Name", "${var.name}"
  ))}"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    EIP_ID                = "${aws_eip.main.id}"
    IAM_AUTHORIZED_GROUPS = "${var.iam_user_groups}"
    SUDOERS_GROUPS        = "${var.iam_sudo_groups}"
    ASSUMEROLE            = "${var.assume_role_arn}"
  }
}

module "ec2" {
  source           = "../ec2-base"
  name             = "${var.name}"
  account_id       = "${local.account_id}"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = ["${var.public_subnet_ids}"]
  subnet_public    = "true"
  image_id         = "${local.image_id}"
  user_data        = "${data.template_file.userdata.rendered}"
  min_size         = "${local.min_size}"
  max_size         = "${local.max_size}"
  desired_capacity = "${local.desired_capacity}"
}

# extend sg
resource "aws_security_group_rule" "pubic-ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${module.ec2.security_group_id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  to_port = 22
  type    = "ingress"
}

# extend role
resource "aws_iam_policy" "main-ip" {
  name        = "${local.name}-ip-policy"
  path        = "/"
  description = "${local.name}-ip Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-ip" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "${aws_iam_policy.main-ip.arn}"
}

resource "aws_iam_policy" "main-iam" {
  name        = "${local.name}-iam-policy"
  path        = "/"
  description = "${local.name} SSH IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${var.assume_role_arn}"
      ]
    }, {
      "Effect": "Allow",
      "Action": "ec2:DescribeTags",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-iam" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "${aws_iam_policy.main-iam.arn}"
}

# ACL
resource "aws_network_acl_rule" "ingress_ssh_public_ipv4" {
  network_acl_id = "${var.network_acl_id}"
  rule_number    = "${var.acl_rule_number}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "ingress_ssh_public_ipv6" {
  network_acl_id  = "${var.network_acl_id}"
  rule_number     = "${var.acl_rule_number+1}"
  egress          = false
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 22
  to_port         = 22
}

resource "aws_network_acl_rule" "egress_ssh_public_ipv4" {
  network_acl_id = "${var.network_acl_id}"
  rule_number    = "${var.acl_rule_number}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "egress_ssh_public_ipv6" {
  network_acl_id  = "${var.network_acl_id}"
  rule_number     = "${var.acl_rule_number+1}"
  egress          = true
  protocol        = "tcp"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 22
  to_port         = 22
}
