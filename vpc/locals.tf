data "aws_region" "current" {}

locals {
  aws_region = "${data.aws_region.current.name}"
}
