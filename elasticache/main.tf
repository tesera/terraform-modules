resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.identifier}-group"
  subnet_ids = ["${var.subnet_ids}"]
}

resource "aws_elasticache_replication_group" "clustermodedisabled" {
  count                         = "${var.cluster_mode_enabled == true ? 0 : 1}"
  automatic_failover_enabled    = "${var.automatic_failover_enabled}"
  replication_group_id          = "${local.identifier}-group"
  replication_group_description = "${local.identifier} Replication Group"
  engine                        = "${var.engine}"
  engine_version                = "${var.engine_version}"
  node_type                     = "${var.node_type}"
  parameter_group_name          = "${var.parameter_group_name}"
  availability_zones            = "${var.availability_zones}"
  subnet_group_name             = "${aws_elasticache_subnet_group.main.name}"
  security_group_ids            = ["${aws_security_group.main.id}"]
  number_cache_clusters         = "${local.number_cache_clusters}"
  maintenance_window            = "${var.maintenance_window}"
  port                          = "${var.port}"
  at_rest_encryption_enabled    = "${var.at_rest_encryption_enabled}"
  transit_encryption_enabled    = "${var.transit_encryption_enabled}"

  lifecycle {
    ignore_changes = ["number_cache_clusters"]
  }

  tags {
    Name      = "${local.identifier}-cluster"
    Terraform = true
  }
}

resource "aws_elasticache_cluster" "replica" {
  count                = "${var.replica_count - local.number_cache_clusters + 1 > 0 ? var.replica_count - local.number_cache_clusters + 1 : 0}"
  cluster_id           = "${local.identifier}-${count.index + 1}"
  replication_group_id = "${aws_elasticache_replication_group.clustermodedisabled.id}"

  tags {
    Name      = "${local.identifier}-${count.index + 1}"
    Terraform = true
  }
}

resource "aws_elasticache_replication_group" "clustermodeenabled" {
  count                         = "${var.cluster_mode_enabled == true ? 1 : 0}"
  automatic_failover_enabled    = "${var.automatic_failover_enabled}"
  replication_group_id          = "${local.identifier}-group"
  replication_group_description = "${local.identifier} Group"
  engine                        = "${var.engine}"
  engine_version                = "${var.engine_version}"
  node_type                     = "${var.node_type}"
  parameter_group_name          = "${var.parameter_group_name}"
  subnet_group_name             = "${aws_elasticache_subnet_group.main.name}"
  security_group_ids            = ["${aws_security_group.main.id}"]
  maintenance_window            = "${var.maintenance_window}"
  port                          = "${var.port}"
  at_rest_encryption_enabled    = "${var.at_rest_encryption_enabled}"
  transit_encryption_enabled    = "${var.transit_encryption_enabled}"

  cluster_mode {
    replicas_per_node_group = "${var.replica_count}"
    num_node_groups         = "${var.num_node_groups}"
  }

  tags {
    Name      = "${local.identifier}-cluster"
    Terraform = true
  }
}
