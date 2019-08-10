output "arn" {
  value = aws_elasticsearch_domain.main.arn
}

output "domain_id" {
  value = aws_elasticsearch_domain.main.domain_id
}

output "domain_name" {
  value = aws_elasticsearch_domain.main.domain_name
}

output "endpoint" {
  value = aws_elasticsearch_domain.main.endpoint
}

output "kibana_endpoint" {
  value = aws_elasticsearch_domain.main.kibana_endpoint
}

output "availability_zones" {
  value = aws_elasticsearch_domain.main.vpc_options[0].availability_zones
}

output "vpc_id" {
  value = aws_elasticsearch_domain.main.vpc_options[0].vpc_id
}

output "security_group_id" {
  value = aws_security_group.main.id
}

