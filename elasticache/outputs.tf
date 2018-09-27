output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "endpoint_address" {
  value = "${element(concat(aws_elasticache_replication_group.clustermodeenabled.*.configuration_endpoint_address, aws_elasticache_replication_group.clustermodedisabled.*.primary_endpoint_address), 0)}"
}

output "member_clusters" {
  value = "${concat(aws_elasticache_replication_group.clustermodeenabled.*.member_clusters, aws_elasticache_replication_group.clustermodedisabled.*.member_clusters)}"
}
