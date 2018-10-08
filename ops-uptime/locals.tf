data "aws_region" "current" {}

data "profile" "current" {}

locals {
  aws_region = "${data.aws_region.current.name}"
  profile    = "${data. profile.current.name}"
}
