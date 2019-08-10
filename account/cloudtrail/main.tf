resource "aws_cloudtrail" "cloudtrail" {
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_logs.arn
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true

  //kms_key_id                    = "${aws_kms_key.cloudtrail.arn}"
  name           = local.name
  s3_bucket_name = local.logging_bucket

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name}-cloudtrail"
    },
  )
}

