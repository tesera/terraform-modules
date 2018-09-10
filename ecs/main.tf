

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-ecs"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    ECS_CLUSTER     = "${aws_ecs_cluster.main.name}"
  }
}

module "ec2" {
  source           = "../ec2"
  name             = "${var.name}-ecs"
  account_id       = "${local.account_id}"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = "${var.private_subnet_ids}"
  image_id         = "${local.image_id}"
  key_name         = "${var.key_name}"
  banner           = "AWS ECS"
  user_data         = "${data.template_file.userdata.rendered}"
  iam_user_groups  = "${var.iam_user_groups}"
  iam_sudo_groups  = "${var.iam_sudo_groups}"
  local_groups     = "docker"
  min_size         = "${local.min_size}"
  max_size         = "${local.max_size}"
  desired_capacity = "${local.desired_capacity}"
  bastion_security_group_id = "${var.bastion_security_group_id}"
}


resource "aws_iam_policy" "main-ecs" {
  name        = "${var.name}-ecs-policy"
  path        = "/"
  description = "${var.name} ECS Policy"

  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll"
      ],
      "Resource": ["${aws_ecs_cluster.main.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-ecs" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "${aws_iam_policy.main-ecs.arn}"
}
