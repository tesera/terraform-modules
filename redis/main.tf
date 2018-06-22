variable "aws_account_id" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "tenant" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "vpc" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "security_group_ids" {
  type = "list"
}

variable "node_type" {
  type = "string"
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.tenant}-${var.env}-main"
  subnet_ids = ["${var.subnet_ids}"]
}

resource "aws_elasticache_cluster" "app_cache" {
  cluster_id           = "${var.tenant}-${var.env}"
  engine               = "redis"
  node_type            = "${var.node_type}"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.main.name}"
  security_group_ids   = ["${var.security_group_ids}"]
}

output "redis_nodes" {
  value = "${aws_elasticache_cluster.app_cache.cache_nodes}"
}
