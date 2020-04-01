# This allow a ecs in a sub account to read from ECR
resource "aws_iam_role" "ecr" {
  count = var.enable_ecr && var.type == "master" ? length(keys(local.sub_accounts)) : 0
  name  = "${element(keys(local.sub_accounts), count.index)}-ecr-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${var.sub_accounts[element(keys(local.sub_accounts), count.index)]}:root"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecr" {
  count = var.enable_ecr && var.type == "master" ? length(keys(local.sub_accounts)) : 0
  role = aws_iam_role.ecr.*.name[count.index]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
