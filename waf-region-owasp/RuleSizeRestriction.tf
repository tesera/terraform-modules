resource "aws_wafregional_rule" "wafrSizeRestrictionRule" {
  depends_on = [
    "aws_wafregional_size_constraint_set.wafgSizeRestrictionSet",
  ]

  name        = "${local.name}wafrSizeRestrictionRule"
  metric_name = "${local.name}wafrSizeRestrictionRule"

  predicate {
    data_id = "${aws_wafregional_size_constraint_set.wafgSizeRestrictionSet.id}"
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_wafregional_size_constraint_set" "wafgSizeRestrictionSet" {
  name = "${local.name}wafgSizeRestrictionSet"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.maxExpectedURISize}"

    field_to_match {
      type = "URI"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.maxExpectedQueryStringSize}"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.maxExpectedBodySize}"

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.maxExpectedCookieSize}"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}