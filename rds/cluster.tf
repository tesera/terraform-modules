resource "aws_rds_cluster" "main" {
  count                               = "${var.type == "cluster" ? 1 : 0}"
  cluster_identifier                  = "${local.identifier}-cluster"
  database_name                       = "${var.db_name}"
  master_username                     = "${var.username}"
  master_password                     = "${var.password}"
  final_snapshot_identifier           = "${local.identifier}-final"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  engine                              = "${var.engine}"
  engine_version                      = "${var.engine_version}"
  engine_mode                         = "${var.engine_mode}"
  storage_encrypted                   = "true"
  db_subnet_group_name                = "${aws_db_subnet_group.main.name}"
  vpc_security_group_ids              = ["${aws_security_group.main.id}"]
  db_cluster_parameter_group_name     = "${var.parameter_group_name}"
  backup_retention_period             = "${var.backup_retention_period}"
  preferred_backup_window             = "${var.backup_window}"
  apply_immediately                   = "${var.apply_immediately}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"

  tags {
    Name      = "${local.identifier} Aurora Cluster"
    Terraform = true
  }
}

resource "aws_rds_cluster_instance" "main" {
  count                   = "${var.type == "cluster" ? var.instance_count : 0}"
  identifier              = "${local.identifier}-instance-${count.index}"
  cluster_identifier      = "${aws_rds_cluster.main.0.id}"
  instance_class          = "${var.instance_type}"
  engine                  = "${var.cluster_engine}"
  engine_version          = "${var.engine_version}"
  publicly_accessible     = "${var.publicly_accessible}"
  db_subnet_group_name    = "${aws_db_subnet_group.main.name}"
  db_parameter_group_name = "${var.parameter_group_name}"
  apply_immediately       = "${var.apply_immediately}"

  tags {
    Name      = "${local.identifier} Aurora Instance"
    Terraform = true
  }
}
