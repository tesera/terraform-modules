resource "aws_db_subnet_group" "db_subnet" {
  name       = "${local.db_id}"
  subnet_ids = ["${var.subnet_ids}"]
}
