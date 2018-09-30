locals {
  name = "${module.defaults.name}"
  tags = "${module.defaults.tags}"

  master_endpoint = "${element(concat(aws_elasticache_replication_group.clustermodeenabled.*.configuration_endpoint_address, aws_elasticache_replication_group.clustermodedisabled.*.primary_endpoint_address), 0)}"
  master_len      = "${length(element(split(".", local.master_endpoint), 0))}"
  member_clusters = "${concat(aws_elasticache_replication_group.clustermodedisabled.*.member_clusters, aws_elasticache_replication_group.clustermodeenabled.*.member_clusters)}"
}
