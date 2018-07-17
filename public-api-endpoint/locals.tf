data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id  = "${data.aws_caller_identity.current.account_id}"
  aws_region  = "${data.aws_region.current.name}"
  name        = "${replace(var.name, "/[_]/", "-")}"
  http_method = "${lower(var.http_method)}"
  path_name   = "${replace(var.resource_path, "/[/:{}]/", "-")}"
  source_dir  = "${var.source_dir != "" ? var.source_dir : "${path.module}/lambda"}"
  policy      = "${var.policy != "" ? var.policy : data.aws_iam_policy_document.default.json}"
}

# Defaults
data "aws_iam_policy_document" "default" {
  statement {
    effect    = "Deny"
    actions   = [
      "*"]
    resources = [
      "*"]
  }
}
