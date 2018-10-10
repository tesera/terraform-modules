module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name}-group"
  subnet_ids = ["${var.private_subnet_ids}"]
}

resource "aws_elasticache_replication_group" "clustermodedisabled" {
  count                         = "${var.type == "cluster" ? 0 : 1}"
  automatic_failover_enabled    = "${var.multi_az}"
  replication_group_id          = "${local.name}-group"
  replication_group_description = "${local.name} Replication Group"
  engine                        = "${var.engine}"
  engine_version                = "${var.version}"
  node_type                     = "${var.instance_type}"
  parameter_group_name          = "${var.parameter_group_name}"
  subnet_group_name             = "${aws_elasticache_subnet_group.main.name}"
  security_group_ids            = ["${aws_security_group.main.id}"]
  number_cache_clusters         = "${var.read_replicas + 1}"
  maintenance_window            = "${var.maintenance_window}"
  port                          = "${var.port}"
  at_rest_encryption_enabled    = "true"
  transit_encryption_enabled    = "true"

  tags = "${merge(local.tags, map(
    "Name", "${local.name}-cluster"
  ))}"
}

resource "aws_elasticache_replication_group" "clustermodeenabled" {
  count                         = "${var.type == "cluster" ? 1 : 0}"
  automatic_failover_enabled    = "${var.multi_az}"
  replication_group_id          = "${local.name}-group"
  replication_group_description = "${local.name} Group"
  engine                        = "${var.engine}"
  engine_version                = "${var.version}"
  node_type                     = "${var.instance_type}"
  parameter_group_name          = "${var.parameter_group_name}"
  subnet_group_name             = "${aws_elasticache_subnet_group.main.name}"
  security_group_ids            = ["${aws_security_group.main.id}"]
  maintenance_window            = "${var.maintenance_window}"
  port                          = "${var.port}"
  at_rest_encryption_enabled    = "true"
  transit_encryption_enabled    = "true"

  cluster_mode {
    replicas_per_node_group = "${var.read_replicas}"
    num_node_groups         = "${var.num_node_groups}"
  }

  tags = "${merge(local.tags, map(
    "Name", "${local.name}-cluster"
  ))}"
}
