//data "template_file" "buildspec" {
//  template = "${file("${path.module}/buildspec.yml")}"
//
//  vars {
//    REPOSITORY_URL                = "${aws_ecr_repository.main.repository_url}"
//  }
//}

module "defaults" {
  source = "../defaults"
  tags   = "${var.default_tags}"
}

locals {
  account_id = "${module.defaults.account_id}"
  aws_region = "${module.defaults.aws_region}"
  name       = "${module.defaults.name}"
  tags       = "${module.defaults.tags}"
}
