variable "name" {
  type = string
}

variable "master_account_id" {
  type = string
}

# TODO developer = aws_iam_role_policy_attachment.developer.arn
variable "roles" {
  type = map(string)
}

