resource "aws_eip" "main" {
  vpc = "true"

  tags {
    Name      = "${var.name}-proxy"
    Terraform = "true"
  }
}

data "template_file" "main-userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    REGION          = "${local.aws_region}"
    EIP_ID          = "${aws_eip.main.id}"
    IAM_USER_GROUPS = "${var.iam_user_groups}"
    IAM_SUDO_GROUPS = "${var.iam_sudo_groups}"

    PROXY_NAME      = "${var.proxy_name}"
    PROXY_PORT      = "${var.proxy_port}"
    #PROXY_HEALTH_PORT = "${local.proxy_health_port}"
    PROXY_ENDPOINT  = "${var.proxy_endpoint}"
  }
}

module "ec2" {
  source                    = "../ec2"
  name                      = "${var.name}-proxy"
  vpc_id                    = "${var.vpc_id}"
  subnet_ids                = "${var.public_subnet_ids}"
  subnet_public             = "true"
  image_id                  = "${local.image_id}"
  key_name                  = "${var.key_name}"
  userdata                  = "${data.template_file.main-userdata.rendered}"
  iam_user_groups           = "${var.iam_user_groups}"
  iam_sudo_groups           = "${var.iam_sudo_groups}"
  min_size                  = "${local.min_size}"
  max_size                  = "${local.max_size}"
  desired_capacity          = "${local.desired_capacity}"
  bastion_security_group_id = "${var.bastion_security_group_id}"
}

resource "aws_iam_policy" "main-ip" {
  name        = "${var.name}-proxy-ip-policy"
  path        = "/"
  description = "${var.name}-proxy-ip Policy"

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
