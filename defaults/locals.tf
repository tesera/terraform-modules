data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id   = "${data.aws_caller_identity.current.account_id}"
  aws_region   = "${data.aws_region.current.name}"
  name = "${replace(var.name, "/[_]/", "-")}"
  tags  = "${merge(map(
    "Terraform", "true",
    "Environment", "unknown",
    "Name","${replace(var.name, "/[_]/", "-")}"
  ), var.tags)}"
  // TODO offer tags in list form https://github.com/hashicorp/terraform/issues/15226#issuecomment-307529116
  // - aws_autoscaling_group
}
