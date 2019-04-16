resource "aws_ecs_cluster" "main" {
  name = "${local.name}"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    ECS_CLUSTER = "${aws_ecs_cluster.main.name}"
  }
}

module "ec2" {
  source                 = "../ec2-base"
  iam_service            = "ec2"              // TODO ["ec2","ecs"]
  name                   = "${local.name}"
  vpc_id                 = "${var.vpc_id}"
  subnet_ids             = [
    "${var.private_subnet_ids}"]
  image_id               = "${local.image_id}"
  instance_type          = "${local.instance_type}"
  user_data              = "${data.template_file.userdata.rendered}"
  min_size               = "${local.min_size}"
  max_size               = "${local.max_size}"
  desired_capacity       = "${local.desired_capacity}"
  volume_type            = "${var.volume_type}"
  volume_size            = "${var.volume_size}"
  efs_ids                = [
    "${var.efs_ids}"]
  efs_security_group_ids = [
    "${var.efs_security_group_ids}"]
  key_name = "${var.key_name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "AmazonECSServiceRolePolicy" {
  name = "${local.name}-AmazonECSServiceRolePolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECSTaskManagement",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteNetworkInterfacePermission",
                "ec2:Describe*",
                "ec2:DetachNetworkInterface",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:RegisterTargets",
                "route53:ChangeResourceRecordSets",
                "route53:CreateHealthCheck",
                "route53:DeleteHealthCheck",
                "route53:Get*",
                "route53:List*",
                "route53:UpdateHealthCheck",
                "servicediscovery:DeregisterInstance",
                "servicediscovery:Get*",
                "servicediscovery:List*",
                "servicediscovery:RegisterInstance",
                "servicediscovery:UpdateInstanceCustomHealthStatus"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECSTagging",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:network-interface/*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonECSServiceRolePolicy" {
  role       = "${module.ec2.iam_role_name}"
  policy_arn = "${aws_iam_policy.AmazonECSServiceRolePolicy.arn}"
}
