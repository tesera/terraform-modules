module "defaults" {
  source = "../../../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  account_id  = "${module.defaults.account_id}"
  region      = "${module.defaults.region}"
  name        = "${module.defaults.name}"
  tags        = "${module.defaults.tags}"
  name        = "${replace(var.name, "/[_]/", "-")}"
  http_method = "${lower(var.http_method)}"
  path_name   = "${replace(var.resource_path, "/[/:{}]/", "-")}"
  source_dir  = "${var.source_dir != "" ? var.source_dir : "${path.module}/lambda"}"
  policy      = "${var.policy != "" ? var.policy : data.aws_iam_policy_document.default.json}"
}

# Defaults
data "aws_iam_policy_document" "default" {
  statement {
    effect = "Deny"

    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}
