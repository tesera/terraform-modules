data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id          = "${data.aws_caller_identity.current.account_id}"
  aws_region          = "${data.aws_region.current.name}"
  name                = "${replace(var.name, "/[_]/", "-")}"
  http_method         = "${lower(var.http_method)}"
  path_name           = "${replace(var.resource_path, "/", "-")}"
  lambda_policy       = "${var.lambda_policy != "" ? var.lambda_policy : data.aws_iam_policy_document.default.json}"
  lambda_path         = "${var.lambda_path != "" ? var.lambda_path : data.archive_file.default.output_base64sha256}"
  lambda_base64sha256 = "${var.lambda_base64sha256 != "" ? var.lambda_base64sha256 : data.archive_file.default.output_base64sha256}"
}

# Defaults
data "archive_file" "default" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/lambda"
}

data "aws_iam_policy_document" "default" {
  statement {
    effect    = "Deny"
    actions   = [
      "*"]
    resources = [
      "*"]
  }
}
