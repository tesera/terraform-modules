/*
resource "aws_kms_key" "main" {
  description = "Terraform Remote State Encryption"
  deletion_window_in_days = 30
  enable_key_rotation = false

  tags {
    Name = "terraform-state${local.name}"
    Terraform = true
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/terraform-state${local.name}"
  target_key_id = "${aws_kms_key.main.key_id}"
}
*/
