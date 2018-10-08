resource "aws_eip" "main" {
  vpc = "true"

  tags {
    Name      = "${var.name}-bastion"
    Terraform = "true"
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    EIP_ID          = "${aws_eip.main.id}"
  }
}

module "ec2" {
  source           = "../ec2"
  name             = "${var.name}-bastion"
  account_id       = "${local.account_id}"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = "${var.public_subnet_ids}"
  subnet_public     = "true"
  image_id         = "${local.image_id}"
  banner           = "Bastion"
  user_data        = "${data.template_file.userdata.rendered}"
  key_name         = "${var.key_name}"
  iam_user_groups  = "${var.iam_user_groups}"
  iam_sudo_groups  = "${var.iam_sudo_groups}"
  min_size         = "${local.min_size}"
  max_size         = "${local.max_size}"
  desired_capacity = "${local.desired_capacity}"
}

# extend sg
resource "aws_security_group_rule" "pubic-ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${module.ec2.security_group_id}"
  cidr_blocks       = [
    "0.0.0.0/0"]
  to_port           = 22
  type              = "ingress"
}

# extend role
resource "aws_iam_policy" "main-ip" {
  name        = "${var.name}-bastion-ip-policy"
  path        = "/"
  description = "${var.name}-bastion-ip Policy"

  policy      = <<EOF
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


# ACL
resource "aws_network_acl_rule" "ingress_ssh_ipv4" {
  network_acl_id = "${var.network_acl_id}"
  rule_number    = "${var.acl_rule_number}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

//resource "aws_network_acl_rule" "ingress_ssh_ipv6" {
//  network_acl_id = "${var.network_acl_id}"
//  rule_number    = "${var.acl_rule_number}"
//  egress         = false
//  protocol       = "tcp"
//  rule_action    = "allow"
//  cidr_block     = "::/0"
//  from_port      = 22
//  to_port        = 22
//}

resource "aws_network_acl_rule" "egress_ssh_ipv4" {
  network_acl_id = "${var.network_acl_id}"
  rule_number    = "${var.acl_rule_number}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

//resource "aws_network_acl_rule" "egress_ssh_ipv6" {
//  network_acl_id = "${var.network_acl_id}"
//  rule_number    = "${var.acl_rule_number}"
//  egress         = true
//  protocol       = "tcp"
//  rule_action    = "allow"
//  cidr_block     = "::/0"
//  from_port      = 22
//  to_port        = 22
//}
