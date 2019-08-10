resource "aws_elasticsearch_domain" "main" {
  domain_name           = local.name
  elasticsearch_version = var.engine_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.node_count
    dedicated_master_enabled = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = var.dedicated_master_count
    zone_awareness_enabled   = var.multi_az
  }

  vpc_options {
    security_group_ids = [aws_security_group.main.id]
    subnet_ids         = var.private_subnet_ids
  }

  node_to_node_encryption {
    enabled = "true"
  }

  encrypt_at_rest {
    enabled = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  ebs_options {
    ebs_enabled = "true"
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    iops        = var.ebs_iops
  }

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      cloudwatch_log_group_arn = log_publishing_options.value.cloudwatch_log_group_arn
      enabled                  = lookup(log_publishing_options.value, "enabled", null)
      log_type                 = log_publishing_options.value.log_type
    }
  }
  dynamic "cognito_options" {
    for_each = var.cognito_options
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      enabled          = lookup(cognito_options.value, "enabled", null)
      identity_pool_id = cognito_options.value.identity_pool_id
      role_arn         = cognito_options.value.role_arn
      user_pool_id     = cognito_options.value.user_pool_id
    }
  }

  access_policies = <<CONFIG
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "es:*",
              "Principal": "*",
              "Effect": "Allow",
              "Resource": "arn:aws:es:${local.region}:${local.account_id}:domain/${local.name}/*"
          }
      ]
  }
  
CONFIG


  tags = merge(
    local.tags,
    {
      "Name" = local.name
    },
  )
}

