resource "aws_efs_file_system" "main" {
  encrypted                       = "true"
  kms_key_id                      = "${var.kms_key_id}"
  performance_mode                = "${var.performance_mode}"
  provisioned_throughput_in_mibps = "${var.provisioned_throughput_in_mibps}"
  throughput_mode                 = "${var.throughput_mode}"
  tags                            = "${local.tags}"
}
