resource "aws_db_instance" "master" {
  auto_minor_version_upgrade      = true
  allow_major_version_upgrade     = false
  allocated_storage               = "${var.allocated_storage}"
  identifier                      = "${var.name}"
  storage_type                    = "${var.storage_type}"
  engine                          = "${var.engine}"
  engine_version                  = "${var.engine_version}"
  instance_class                  = "${var.instance_class}"
  name                            = "${var.db_name}"
  parameter_group_name            = "${var.parameter_group_name}"
  apply_immediately               = true
  # Confidentiality
  username                        = "${var.username}"
  password                        = "${var.password}"
  publicly_accessible             = false
  db_subnet_group_name            = "${aws_db_subnet_group.db_subnet.name}"
  vpc_security_group_ids          = [
    "${aws_security_group.db.id}"]
  # TODO test out `iam_database_authentication_enabled` for db user access
  # TODO research and apply `kms_key_id`

  # TODO add in `storage_encrypted`
  # Integrity
  enabled_cloudwatch_logs_exports = [ "audit" ]
  # TODO add in `monitoring_interval` & `monitoring_role_arn`
  final_snapshot_identifier       = "${var.name}"
  backup_retention_period         = "${var.backup_retention_period}"
  backup_window                   = "${var.backup_window}"
  # Auditiability
  multi_az                        = "${var.multi_az}"

}

# TODO add in replicate db with `replicate_source_db`
//resource "aws_db_instance" "slave" {
//  replicate_source_db = "${aws_db_instance.master.name}"
//}
