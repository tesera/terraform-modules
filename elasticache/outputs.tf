output "security_group_id" {
  value = aws_security_group.main.id
}

output "endpoint" {
  value = local.master_endpoint
}

output "replica_endpoints" {
  value = formatlist(
    "%s%s",
    local.member_clusters[0],
    substr(
      local.master_endpoint,
      local.master_len,
      length(local.master_endpoint) - local.master_len,
    ),
  )
}

output "port" {
  value = var.port
}

