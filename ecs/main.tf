resource "aws_ecs_cluster" "main" {
  name = "${var.name}-ecs"
}

resource "aws_security_group" "main" {
  name   = "${var.name}-ecs"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_iam_role" "main" {
  name               = "${var.name}-ecs-role"

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

resource "aws_iam_policy" "main-iam" {
  name        = "${var.name}-ecs-iam-policy"
  path        = "/"
  description = "${var.name} ECS SSH IAM Policy"

  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListUsers",
        "iam:GetGroup"
      ],
      "Resource": "*"
    }, {
      "Effect": "Allow",
      "Action": [
        "iam:GetSSHPublicKey",
        "iam:ListSSHPublicKeys"
      ],
      "Resource": [
        "arn:aws:iam::${local.account_id}:user/*"
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
  role       = "${aws_iam_role.main.name}"
  policy_arn = "${aws_iam_policy.main-iam.arn}"
}

resource "aws_iam_policy" "main-logs" {
  name        = "${var.name}-ecs-logs-policy"
  path        = "/"
  description = "${var.name} ECS Logs Policy"

  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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

resource "aws_iam_role_policy_attachment" "main-logs" {
  role       = "${aws_iam_role.main.name}"
  policy_arn = "${aws_iam_policy.main-logs.arn}"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.name}-ecs-instance-profile"
  role = "${aws_iam_role.main.name}"
}

resource "aws_launch_configuration" "main" {
  name_prefix                 = "${var.name}-ecs-"
  image_id                    = "${local.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.main.name}"
  security_groups             = [
    "${aws_security_group.main.id}"]
  user_data                   = "${data.template_file.main-userdata.rendered}"
  ebs_optimized               = "false"
  enable_monitoring           = "true"

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
    ECS_CLUSTER = "${aws_ecs_cluster.main.name}"
    IAM_USER_GROUPS = "${var.iam_user_groups}"
    IAM_SUDO_GROUPS = "${var.iam_sudo_groups}"
  }
}

resource "aws_autoscaling_group" "main" {
  name                      = "${var.name}-ecs-asg"
  max_size                  = "${local.max_size}"
  min_size                  = "${local.min_size}"
  desired_capacity          = "${local.desired_capacity}"
  health_check_grace_period = 30
  launch_configuration      = "${aws_launch_configuration.main.name}"
  vpc_zone_identifier       = [
    "${var.private_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.name}-ecs"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = "true"
  }
}
