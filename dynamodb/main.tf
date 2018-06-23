resource "aws_dynamodb_table" "main" {
  name           = "${var.table_name}"
  read_capacity  = "${var.min_read_capacity}"
  write_capacity = "${var.min_write_capacity}"
  hash_key       = "${var.hash_key}"
  range_key      = "${var.range_key}"

  attribute {
    name = "${var.hash_key}"
    type = "S"
  }

  attribute {
    name = "${var.range_key}"
    type = "S"
  }

  tags {
    Name = "Stage"
  }
}

resource "aws_appautoscaling_target" "read_target" {
  max_capacity       = "${var.max_read_capacity}"
  min_capacity       = "${var.min_read_capacity}"
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = "${var.read_target_value}"
  }
}

resource "aws_appautoscaling_target" "write_target" {
  max_capacity       = "${var.max_write_capacity}"
  min_capacity       = "${var.min_write_capacity}"
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = "${var.write_target_value}"
  }
}
