resource "aws_sns_topic" "rds-sns-topic" {
  name = "${local.identifier}-rds-topic"
}

resource "aws_cloudwatch_metric_alarm" "rds-cpu-alarm" {
  alarm_name        = "${local.identifier} RDS CPU alarm"
  alarm_description = "${local.identifier} HIGH RDS CPU utilization"
  namespace         = "AWS/RDS"
  metric_name       = "CPUUtilization"

  dimensions = {
    DBInstanceIdentifier = local.identifier
  }

  statistic           = "Average"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  period              = 300
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.rds-sns-topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds-free-space" {
  alarm_name        = "${local.identifier} RDS free space alarm"
  alarm_description = "${local.identifier} LOW free storage space"
  namespace         = "AWS/RDS"
  metric_name       = "FreeStorageSpace"

  dimensions = {
    DBInstanceIdentifier = local.identifier
  }

  statistic           = "Average"
  evaluation_periods  = 1
  period              = 300
  threshold           = var.free_space_alarm_threshold
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_sns_topic.rds-sns-topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds-swap-usage" {
  alarm_name        = "${local.identifier} RDS swap usage alarm"
  alarm_description = "${local.identifier} swap usage"
  namespace         = "AWS/RDS"
  metric_name       = "SwapUsage"

  dimensions = {
    DBInstanceIdentifier = local.identifier
  }

  statistic           = "Average"
  evaluation_periods  = 1
  period              = 300
  threshold           = var.swap_alarm_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.rds-sns-topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds-read-latency" {
  alarm_name        = "${local.identifier} RDS read latency alarm"
  alarm_description = "${local.identifier} HIGH read latency"
  namespace         = "AWS/RDS"
  metric_name       = "ReadLatency"

  dimensions = {
    DBInstanceIdentifier = local.identifier
  }

  statistic           = "Average"
  evaluation_periods  = 1
  period              = 300
  threshold           = var.read_latency_alarm_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.rds-sns-topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds-write-latency" {
  alarm_name        = "${local.identifier} RDS write latency alarm"
  alarm_description = "${local.identifier} HIGH write latency"
  namespace         = "AWS/RDS"
  metric_name       = "WriteLatency"

  dimensions = {
    DBInstanceIdentifier = local.identifier
  }

  statistic           = "Average"
  evaluation_periods  = 1
  period              = 300
  threshold           = var.write_latency_alarm_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.rds-sns-topic.arn]
}

