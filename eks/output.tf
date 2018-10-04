output "name" {
  value = "${aws_eks_cluster.main.name}"
}

# EC2 Output
output "iam_role_name" {
  value = "${module.ec2.iam_role_name}"
}

output "security_group_id" {
  value = "${module.ec2.security_group_id}"
}

output "billing_suggestion" {
  value = "${module.ec2.billing_suggestion}"
}


//output "kubeconfig" {
//  value = "${local.kubeconfig}"
//}
//
//output "config-map-aws-auth" {
//  value = "${local.config-map-aws-auth}"
//}
