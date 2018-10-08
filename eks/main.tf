module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${local.cluster_name}"
  subnets         = [
    "${var.private_subnet_ids}"]
  tags            = "${local.tags}"
  vpc_id          = "${var.vpc_id}"
  manage_aws_auth = true
  map_accounts = ["${local.account_id}"]
  map_users       = [
    {
      user_arn = "arn:aws:iam::${local.account_id}:user/will.farrell"
      username = "will.farrell"
      group    = "system:masters"
    }]
//  map_roles       = [
//    {
//      user_arn = "arn:aws:iam::${local.account_id}:user/will.farrell"
//      username = "will.farrell"
//      group    = "system:masters"
//    }]
  worker_groups   = [
    "${list(map(
        "asg_desired_capacity","${local.desired_capacity}",
        "asg_maz_size","${local.max_size}",
        "asg_min_size","${local.min_size}",
        "instance_type", "${var.instance_type != "" ? var.instance_type : "t2.micro"}",
        "root_volume_size","50",
        "root_volume_type","gp2",
        "key_name","${var.key_name}",
        "pre_userdata", "${data.template_file.userdata.rendered}"
      ))}"]
}

resource "aws_security_group_rule" "ssh" {
  count                    = "${var.bastion_security_group_id != "" ? 1 : 0}"
  security_group_id        = "${module.eks.worker_security_group_id}"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${var.bastion_security_group_id}"
}
