resource "aws_eip" "main" {
  vpc = "true"

  tags {
    key                 = "Name"
    value               = "${var.name}-bastion"
  }

  tags {
    key                 = "Terraform"
    value               = "true"
  }
}

resource "aws_security_group" "main" {
  name   = "${var.name}-bastion"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "main" {
  name = "${var.name}-bastion-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "main" {
  name        = "${var.name}-bastion-policy"
  path        = "/"
  description = "${var.name} Bastion Policy"

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = "${aws_iam_role.main.name}"
  policy_arn = "${aws_iam_policy.main.arn}"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.name}-bastion-instance-profile"
  role = "${aws_iam_role.main.name}"
}

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.name}-bastion-"
  image_id             = "${local.image_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.main.name}"
  security_groups      = ["${aws_security_group.main.id}"]
  user_data            = "${data.template_file.main-userdata.rendered}"
  #user_data_base64 = "${data.template_file.main-userdata.}"
  ebs_optimized        = "false"
  enable_monitoring    = "true"

  # Assign EIP in user_data instead
  associate_public_ip_address = "false"

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

data "template_file" "main-userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    REGION = "${local.aws_region}"
    EIP_ID = "${aws_eip.main.id}"
  }
}

output "template" {
  value = "${data.template_file.main-userdata.rendered}"
}

resource "aws_autoscaling_group" "main" {
  name                 = "${var.name}-bastion-asg"
  max_size             = "${local.max_size}"
  min_size             = "${local.min_size}"
  desired_capacity     = "${local.desired_capacity}"
  health_check_grace_period = 30
  launch_configuration = "${aws_launch_configuration.main.name}"
  vpc_zone_identifier  = ["${var.public_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.name}-bastion"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = "true"
  }
}
