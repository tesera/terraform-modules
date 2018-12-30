output "name" {
  value = "${local.cluster_name}"
}

# EC2 Output
output "iam_role_name" {
  value = "${module.eks.worker_iam_role_name}"
}

output "security_group_id" {
  value = "${module.eks.worker_security_group_id}"
}

output "billing_suggestion" {
  value = "Reserved Instances: ${var.instance_type} x ${local.desired_capacity} (${local.region})"
}
