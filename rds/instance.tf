resource "aws_db_instance" "main" {
  count                               = var.type == "cluster" ? 0 : 1
  auto_minor_version_upgrade          = true
  allow_major_version_upgrade         = false
  allocated_storage                   = var.allocated_storage
  identifier                          = "${local.name}-${var.engine}-${var.type}"
  storage_type                        = var.storage_type
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_type
  name                                = local.db_name
  parameter_group_name                = local.parameter_group_name
  apply_immediately                   = var.apply_immediately
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # Confidentiality
  username             = var.username
  password             = var.password
  publicly_accessible  = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.main.id,
  ]

  # TODO test out `iam_database_authentication_enabled` for db user access
  # TODO research and apply `kms_key_id`

  storage_encrypted = replace(var.instance_type, "micro", "") == var.instance_type

  # Integrity
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights

  # TODO add in `monitoring_interval` & `monitoring_role_arn`
  final_snapshot_identifier = "${local.identifier}-final"
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window

  # Availability
  multi_az = var.multi_az
  tags = merge(
    local.tags,
    {
      Name = "${local.identifier} Master/Slave"
    }
  )
}

resource "aws_db_instance" "replica" {
  count               = var.type == "cluster" ? 0 : var.replica_count
  replicate_source_db = aws_db_instance.main[0].name

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = max(var.max_allocated_storage, var.allocated_storage)
  identifier                  = "${local.name}-${var.engine}-${var.type}-replica-${count.index}"
  storage_type                = var.storage_type
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_type
  name                        = local.db_name
  parameter_group_name        = local.parameter_group_name
  apply_immediately           = true

  # Confidentiality
  username             = var.username
  publicly_accessible  = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
  aws_security_group.main.id]

  # TODO test out `iam_database_authentication_enabled` for db user access
  # TODO research and apply `kms_key_id`

  storage_encrypted = replace(var.instance_type, "micro", "") == var.instance_type

  # Integrity
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights

  # TODO add in `monitoring_interval` & `monitoring_role_arn`
  backup_retention_period = 0

  # Availability
  multi_az = false
  tags = merge(
    local.tags,
    {
      Name = "${local.identifier} Replica"
    }
  )
}

