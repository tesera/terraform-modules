resource "aws_eks_cluster" "main" {
  name       = "${local.cluster_name}"
  role_arn   = "${aws_iam_role.cluster.arn}"

  vpc_config {
    security_group_ids = [
      "${aws_security_group.cluster.id}"]
    subnet_ids         = [
      "${var.private_subnet_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy",
  ]
}

data "template_file" "kubeconfig" {
  template = "${path.module}/kubeconfig.yml.tpl"

  vars {
    name                       = "${local.cluster_name}"
    server                     = "${aws_eks_cluster.main.endpoint}"
    certificate-authority-data = "${aws_eks_cluster.main.certificate_authority.0.data}"
  }
}

resource "null_resource" "kubeconfig" {

  triggers {
    config_path = "${data.template_file.kubeconfig.rendered}"
  }

  provisioner "local-exec" {
    command = "cat '${data.template_file.kubeconfig.rendered}' > ${path.module}/kubeconfig.yml && aws eks update-kubeconfig --kubeconfig ${path.module}/kubeconfig.yml"
  }
}

# IAM
resource "aws_iam_role" "cluster" {
  name               = "${local.cluster_name}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster.name}"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster.name}"
}

# SG
resource "aws_security_group" "cluster" {
  name   = "${local.cluster_name}-cluster"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = "${merge(local.tags, map(
    "Name", "${local.cluster_name}"
  ))}"
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${module.ec2.security_group_id}"
  to_port                  = 443
  type                     = "ingress"
}
