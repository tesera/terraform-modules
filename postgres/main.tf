variable "aws_account_id" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "tenant" {
  type = "string"
}

variable "db_name" {
  type = "string"
}

variable "username" {
  type = "string"
}

variable "password" {
  type = "string"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.tenant}-${var.env}"
  subnet_ids = ["${var.subnet_ids}"]
}

resource "aws_db_instance" "main" {
  allocated_storage         = 200
  backup_retention_period   = 7
  backup_window             = "06:00-07:00"
  identifier                = "${var.tenant}-${var.env}"
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "9.5.10"
  instance_class            = "db.t2.micro"
  name                      = "${var.db_name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  parameter_group_name      = "default.postgres9.5"
  publicly_accessible       = true
  db_subnet_group_name      = "${aws_db_subnet_group.main.name}"
  vpc_security_group_ids    = ["${var.vpc_security_group_ids}"]
  final_snapshot_identifier = "${var.tenant}-${var.env}"
  apply_immediately         = true
}

output "postgres_endpoint" {
  value = "${aws_db_instance.main.endpoint}"
}

output "password" {
  value = "${aws_db_instance.main.password}"
}

output "username" {
  value = "${aws_db_instance.main.username}"
}
