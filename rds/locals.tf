locals {
  db_name = "${var.db_name != "" ? var.db_name : var.name}"
}