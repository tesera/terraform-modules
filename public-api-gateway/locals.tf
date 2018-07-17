data "aws_region" "current" {}

locals {
  aws_region = "${data.aws_region.current.name}"
  name = "${replace(var.name, "/[_]/", "-")}"
  api_path = "api"

  authorizer_path = "${var.authorizer_path != "" ? var.authorizer_path : "${path.module}/authorizer"}"
}
