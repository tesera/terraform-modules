resource "aws_rds_cluster" "main" {
  cluster_identifier        = "${var.cluster_name}"
  database_name             = "${var.db_name}"
  master_username           = "${var.username}"
  master_password           = "${var.password}"
  final_snapshot_identifier = "${var.name}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"      #true
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  engine_mode               = "${var.engine_mode}"
  vpc_security_group_ids    = ["${aws_security_group.main.id}"]
  tags                      = "${var.tags}"
}

resource "aws_rds_cluster_instance" "main" {
  count                   = "${var.instance_count}"
  identifier              = "${var.cluster_name}-instance"
  cluster_identifier      = "${aws_rds_cluster.main.id}"
  instance_class          = "${var.instance_class}"
  publicly_accessible     = "${var.publicly_accessible}"
  db_subnet_group_name    = "${aws_db_subnet_group.main.name}"
  parameter_group_name    = "${var.parameter_group_name}"
  apply_immediately       = "${var.apply_immediately}"
  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.backup_window}"
}

resource "aws_db_instance" "main" {
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
  apply_immediately           = true

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
  final_snapshot_identifier = "${var.name}"
  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.backup_window}"
  # Availability
  multi_az = "${var.multi_az}"
  tags {
    Name      = "${var.name} ${var.engine} Master/Slave"
    Terraform = true
  }
}
