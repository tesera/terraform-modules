module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  name       = "${module.defaults.name}"
  tags       = "${module.defaults.tags}"
  identifier = "${var.name}-${var.engine}-${var.type}"
  db_name    = "${var.db_name != "" ? var.db_name : var.name}"
  endpoint   = "${element(concat(aws_rds_cluster.main.*.endpoint, aws_db_instance.main.*.address),0)}"
  port       = "${element(concat(aws_rds_cluster.main.*.port, aws_db_instance.main.*.port),0)}"
}
