resource "aws_eip" "main" {
  vpc = "true"

  tags = merge(
    local.tags,
    {
      "Name" = local.name
    },
  )
}

data "template_file" "main-userdata" {
  template = file("${path.module}/user_data.sh")

  vars = {
    EIP_ID     = aws_eip.main.id
    PROXY_NAME = var.proxy_name
    PROXY_PORT = var.proxy_port
    #PROXY_HEALTH_PORT = "${local.proxy_health_port}"
    PROXY_ENDPOINT = var.proxy_endpoint
  }
}

module "ec2" {
  source                    = "../ec2"
  name                      = local.name
  vpc_id                    = var.vpc_id
  subnet_ids                = var.public_subnet_ids
  subnet_public             = "true"
  image_id                  = local.image_id
  banner                    = "Proxy"
  userdata                  = data.template_file.main-userdata.rendered
  iam_user_groups           = var.iam_user_groups
  iam_sudo_groups           = var.iam_sudo_groups
  min_size                  = local.min_size
  max_size                  = local.max_size
  desired_capacity          = local.desired_capacity
  bastion_security_group_id = var.bastion_security_group_id
}

resource "aws_iam_policy" "main-ip" {
  name        = "${local.name}-ip-policy"
  path        = "/"
  description = "${local.name} IP Policy"

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
  role       = module.ec2.iam_role_name
  policy_arn = aws_iam_policy.main-ip.arn
}

# ACL
resource "aws_network_acl_rule" "ingress_http_ipv4" {
  network_acl_id = var.network_acl_id
  rule_number    = var.acl_rule_number
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = var.proxy_port
  to_port        = var.proxy_port
}

resource "aws_network_acl_rule" "egress_http_ipv4" {
  network_acl_id = var.network_acl_id
  rule_number    = var.acl_rule_number
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = var.proxy_port
  to_port        = var.proxy_port
}

