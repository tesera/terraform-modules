module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  name                 = module.defaults.name
  tags                 = module.defaults.tags
  identifier           = "${var.name}-${var.engine}-${var.type}"
  engine_family        = "${var.engine}${var.engine_version}"
  parameter_group_name = var.parameter_group_name != "" ? var.parameter_group_name : "default.${local.engine_family}"
  db_name              = var.db_name != "" ? var.db_name : var.name
  endpoint = element(
    concat(
      aws_rds_cluster.main.*.endpoint,
      aws_db_instance.main.*.address,
    ),
    0,
  )
  port = element(
    concat(aws_rds_cluster.main.*.port, aws_db_instance.main.*.port),
    0,
  )
}

