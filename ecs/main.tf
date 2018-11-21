resource "aws_ecs_cluster" "main" {
  name = "${var.name}-ecs"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    ECS_CLUSTER = "${aws_ecs_cluster.main.name}"
  }
}

module "ec2" {
  source                 = "../ec2-base"
  name                   = "${var.name}-ecs"
  account_id             = "${local.account_id}"
  vpc_id                 = "${var.vpc_id}"
  subnet_ids             = "${var.private_subnet_ids}"
  image_id               = "${local.image_id}"
  instance_type          = "${local.instance_type}"
  user_data              = "${data.template_file.userdata.rendered}"
  min_size               = "${local.min_size}"
  max_size               = "${local.max_size}"
  desired_capacity       = "${local.desired_capacity}"
  efs_ids                = "${var.efs_ids}"
  efs_security_group_ids = "${var.efs_security_group_ids}"
}

resource "aws_iam_role_policy_attachment" "main-ecs" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
