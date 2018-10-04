data "template_file" "worker" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    APISERVER_ENDPOINT = "${aws_eks_cluster.main.endpoint}"
    CLUSTER_CA         = "${aws_eks_cluster.main.certificate_authority.0.data}"
    CLUSTER_NAME       = "${local.name}-eks"
    ROLE_ARN           = "${module.ec2.iam_role_arn}"
  }
}

module "ec2" {
  source                    = "../ec2"
  name                      = "${var.name}-eks"
  account_id                = "${local.account_id}"
  vpc_id                    = "${var.vpc_id}"
  subnet_ids                = "${var.private_subnet_ids}"
  image_id                  = "${local.image_id}"
  key_name                  = "${var.key_name}"
  banner                    = "AWS EKS"
  user_data                 = "${data.template_file.worker.rendered}"
  iam_user_groups           = "${var.iam_user_groups}"
  iam_sudo_groups           = "${var.iam_sudo_groups}"
  iam_local_groups          = "docker"
  min_size                  = "${local.min_size}"
  max_size                  = "${local.max_size}"
  desired_capacity          = "${local.desired_capacity}"
  bastion_security_group_id = "${var.bastion_security_group_id}"

  default_tags = "${merge(local.tags, map(
    "kubernetes.io/cluster/${aws_eks_cluster.main.name}", "owned"
  ))}"
}

# IAM
resource "aws_iam_role_policy_attachment" "worker-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${module.ec2.iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "worker-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${module.ec2.iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "worker-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${module.ec2.iam_role_name}"
}

resource "aws_iam_instance_profile" "worker" {
  name = "t${local.name}-eks"
  role = "${module.ec2.iam_role_name}"
}

# SG
resource "aws_security_group_rule" "worker-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${module.ec2.security_group_id}"
  source_security_group_id = "${module.ec2.security_group_id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${module.ec2.security_group_id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}
