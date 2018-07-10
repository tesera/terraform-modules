data "aws_region" "current" {}

locals {
  aws_region = "${data.aws_region.current.name}"
  name = "${replace(var.name, "/[_]/", "-")}"
  sse_algorithm = "AES256"
}
