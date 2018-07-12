data "aws_region" "current" {}

locals {
  aws_region = "${data.aws_region.current.name}"
  name = "${replace(var.name, "/[_]/", "-")}"
  api_path = "api"

  authorizer_path = "${var.authorizer_path != "" ? var.authorizer_path : data.archive_file.authorizer.output_path}"
  authorizer_base64sha256 = "${var.authorizer_base64sha256 != "" ? var.authorizer_base64sha256 : data.archive_file.authorizer.output_base64sha256}}"
}
