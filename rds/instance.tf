resource "aws_db_instance" "main" {
  count                       = "${var.type == "cluster" ? 0 : 1}"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  allocated_storage           = "${var.allocated_storage}"
  identifier                  = "${var.name}-${var.engine}"
  storage_type                = "${var.storage_type}"
  engine                      = "${var.engine}"
  engine_version              = "${var.engine_version}"
  instance_class              = "${var.instance_class}"
  name                        = "${local.db_name}"
  parameter_group_name        = "${var.parameter_group_name}"
  apply_immediately           = "${var.apply_immediately}"

  # Confidentiality
  username             = "${var.username}"
  password             = "${var.password}"
  publicly_accessible  = "${var.publicly_accessible}"
  db_subnet_group_name = "${aws_db_subnet_group.main.name}"

  vpc_security_group_ids = [
    "${aws_security_group.main.id}",
  ]

  # TODO test out `iam_database_authentication_enabled` for db user access
  # TODO research and apply `kms_key_id`

  storage_encrypted = "${replace(var.instance_class, "micro", "") == var.instance_class}"
  # Integrity
  # TODO add back in
  #enabled_cloudwatch_logs_exports = [ "audit" ]
  # TODO add in `monitoring_interval` & `monitoring_role_arn`
  final_snapshot_identifier = "${local.identifier}-final"
  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.backup_window}"
  # Availability
  multi_az = "${var.multi_az}"
  tags {
    Name      = "${local.identifier} Master/Slave"
    Terraform = true
  }
}

resource "aws_db_instance" "replica" {
  count               = "${var.type == "cluster" ? 0 : var.replica_count}"
  replicate_source_db = "${aws_db_instance.main.name}"

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  allocated_storage           = "${var.allocated_storage}"
  identifier                  = "${var.name}-replica-${count.index}"
  storage_type                = "${var.storage_type}"
  engine                      = "${var.engine}"
  engine_version              = "${var.engine_version}"
  instance_class              = "${var.instance_class}"
  name                        = "${local.db_name}"
  parameter_group_name        = "${var.parameter_group_name}"
  apply_immediately           = true

  # Confidentiality
  username               = "${var.username}"
  publicly_accessible    = "${var.publicly_accessible}"
  db_subnet_group_name   = "${aws_db_subnet_group.main.name}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]

  # TODO test out `iam_database_authentication_enabled` for db user access
  # TODO research and apply `kms_key_id`

  storage_encrypted = "${replace(var.instance_class, "micro", "") == var.instance_class}"
  # Integrity
  # TODO add back in
  # enabled_cloudwatch_logs_exports = [ "audit" ]
  # TODO add in `monitoring_interval` & `monitoring_role_arn`
  backup_retention_period = 0
  # Availability
  multi_az = false
  tags {
    Name      = "${var.name} ${var.engine} Replica"
    Terraform = true
  }
}
