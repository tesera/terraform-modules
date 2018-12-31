# Elasticache
Creates a Redis Elasticache replication group.

## Features
- Elasticache cluster - support for cluster mode disabled and cluster mode enabled - https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/Replication.Redis-RedisCluster.html
- Cache subnet group to be used for the replication group

### Module
### standalone mode
```hcl-terraform
module "elasticache" {
  source             = "git@github.com:tesera/terraform-modules//elasticache"
  name               = "redis-name"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-00000000000000001"]
  vpc_id             = "vpc-00000000"
  instance_type      = "cache.m3.medium"
  replica_count      = 1
  multi_az           = "true"
  security_group_ids = ["${module.bastion.security_group_id}"]
}
```

### cluster mode
```hcl-terraform
module "elasticache" {
  source             = "git@github.com:tesera/terraform-modules//elasticache"
  type               = "cluster"
  name               = "redis-name"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-00000000000000001"]
  vpc_id             = "vpc-00000000"
  replica_count      = 1
  multi_az           = "true"
  security_group_ids = ["${module.bastion.security_group_id}"]
  num_node_groups    = 2
}
```

## Input
- **name:** name of the elasticache cluster.
- **type:** is cluster mode enabled? [Default: `service`]. Valid values: cluster, service. If cluster is selected multi_az must be true.
- **engine:** the name of the cache engine to be used for the clusters in this replication group. [Default: `redis`]. Valid values: at the moment only `redis` is supported
- **engine_version:** the version number of the cache engine to be used for the cache clusters in this replication group. [Default `5.0`]
- **port:** the port number on which each of the cache nodes will accept connections. [Default: `6379`].
- **parameter_group_name:** the name of the parameter group to associate with this replication group. If this argument is omitted, the default cache parameter group for the engine is used.
- **vpc_id:** VPC id.
- **private_subnet_ids:** list of VPC subnet IDs.
- **instance_type:** the compute and memory capacity of the nodes in the node group. [Default `cache.t2.micro`]
- **maintenance_window:** specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. [Default: sun:05:00-sun:09:00].
- **apply_immediately:** specifies whether any modifications are applied immediately, or during the next maintenance window. [Default: false].
- **replica_count:** specify the number of replica nodes. [Default: 0]. Valid values are 0 to 5. Changing this number when cluster_mode_enabled = true will force a new resource.
- **multi_az:** specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If true, Multi-AZ is enabled for this replication group. If false, Multi-AZ is disabled for this replication group. Must be enabled for Redis (cluster mode enabled) replication groups. [Default: true].
- **node_count:** - specify the number of node groups (shards) for cluster mode enabled replication groups. Changing this number will trigger an online resizing operation before other settings modifications.
- **security_group_ids:** list of security group ids which are going to be granted access to the replication group.

## Output

- **security_group_id:** the security group that was created and associated with this replication group.
- **endpoint:** the address of the replication group configuration endpoint.
- **replica_endpoints:** the identifiers of all the nodes that are part of this replication group.
- **port:** the port number on which each of the cache nodes will accept connections.


