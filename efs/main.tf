resource "aws_efs_file_system" "main" {
  encrypted                       = "true"
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  tags = merge(
    local.tags,
    {
      "Name" = local.name
    },
  )
}

resource "aws_efs_mount_target" "main" {
  count          = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = var.subnet_ids[count.index]

  security_groups = [
    aws_security_group.main.id,
  ]
}

