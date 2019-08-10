output "public_ip" {
  value = aws_eip.main.public_ip
}

# EC2 Output
output "iam_role_name" {
  value = module.ec2.iam_role_name
}

output "security_group_id" {
  value = module.ec2.security_group_id
}

output "billing_suggestion" {
  value = module.ec2.billing_suggestion
}

