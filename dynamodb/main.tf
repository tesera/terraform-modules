variable "env" {}

resource "aws_dynamodb_table" "registration_digests" {
  name           = "${local.registration_digests_table_name}"
  read_capacity  = "${var.registration_digests_min_read_capacity}"
  write_capacity = "${var.registration_digests_min_write_capacity}"
  hash_key       = "digest"
  range_key      = "disasterId"

  attribute {
    name = "digest"
    type = "S"
  }

  attribute {
    name = "disasterId"
    type = "S"
  }

  tags {
    Name        = "Stage"
    Environment = "${var.env}"
  }
}

resource "aws_dynamodb_table" "registration_exports" {
  name           = "${local.registration_exports_table_name}"
  read_capacity  = "${var.registration_exports_min_read_capacity}"
  write_capacity = "${var.registration_exports_min_write_capacity}"
  hash_key       = "registrationId"

  attribute {
    name = "registrationId"
    type = "S"
  }

  ttl {
    enabled        = true
    attribute_name = "timeToExist"
  }

  server_side_encryption {
    enabled = true
  }

  tags {
    Name        = "Stage"
    Environment = "${var.env}"
  }
}

resource "aws_appautoscaling_target" "registration_digests_read_target" {
  max_capacity       = "${var.registration_digests_max_read_capacity}"
  min_capacity       = "${var.registration_digests_min_read_capacity}"
  resource_id        = "table/${local.registration_digests_table_name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "registration_digests_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.registration_digests_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.registration_digests_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.registration_digests_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.registration_digests_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = "${var.registration_digests_read_target_value}"
  }
}

resource "aws_appautoscaling_target" "registration_digests_write_target" {
  max_capacity       = "${var.registration_digests_max_write_capacity}"
  min_capacity       = "${var.registration_digests_min_write_capacity}"
  resource_id        = "table/${local.registration_digests_table_name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "registration_digests_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.registration_digests_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.registration_digests_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.registration_digests_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.registration_digests_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = "${var.registration_digests_write_target_value}"
  }
}

resource "aws_appautoscaling_target" "registration_exports_read_target" {
  max_capacity       = "${var.registration_exports_max_read_capacity}"
  min_capacity       = "${var.registration_exports_min_read_capacity}"
  resource_id        = "table/${local.registration_exports_table_name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "registration_exports_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.registration_exports_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.registration_exports_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.registration_exports_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.registration_exports_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = "${var.registration_exports_read_target_value}"
  }
}

resource "aws_appautoscaling_target" "registration_exports_write_target" {
  max_capacity       = "${var.registration_exports_max_write_capacity}"
  min_capacity       = "${var.registration_exports_min_write_capacity}"
  resource_id        = "table/${local.registration_exports_table_name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "registration_exports_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.registration_exports_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.registration_exports_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.registration_exports_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.registration_exports_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = "${var.registration_exports_write_target_value}"
  }
}
