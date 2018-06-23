resource "aws_db_instance" "master" {
  allocated_storage         = "${var.allocated_storage}"
  backup_retention_period   = "${var.backup_retention_period}"
  backup_window             = "${var.backup_window}"
  identifier                = "${var.name}"
  storage_type              = "${var.storage_type}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.db_name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  parameter_group_name      = "${var.parameter_group_name}"
  publicly_accessible       = true
  db_subnet_group_name      = "${aws_db_subnet_group.db_subnet.name}"
  vpc_security_group_ids    = ["${aws_security_group.db.id}"]
  final_snapshot_identifier = "${var.name}"
  apply_immediately         = true
  multi_az                  = "${var.multi_az}"
}
