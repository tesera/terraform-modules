locals {
  identifier = "${var.name}-${var.engine}"
  az_count   = "${length(var.availability_zones)}"

  # The logic here is:
  # 1. If preferred availability zones (var.availability_zones) are specified, their count must match the number_cache_clusters
  # 2. If preferred availability zones are not specified:
  #   2.1 if automatic_failover_enabled = true we are going to create cache replication group with 2 nodes, 
  #     and if more than 1 additional read replicas are specified in var.replica_count, those will be added with the aws_elasticache_cluster.replica resource 
  #     (the first replica is added as a part of the automatic_failover_enabled = true requirement)
  #   2.2 if automatic_failover_enabled = false we are going to create cache replication group with 1 node + the number of the read replicas specified in var.replica_count
  number_cache_clusters = "${local.az_count > 0 ? local.az_count : (var.automatic_failover_enabled == "true" ? 2 : 1)}"
}
