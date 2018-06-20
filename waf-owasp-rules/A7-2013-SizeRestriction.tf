resource "aws_waf_rule" "wafrSizeRestrictionRule" {
  depends_on = [
    "aws_waf_size_constraint_set.wafgSizeRestrictionSet",
  ]

  name        = "${var.name}wafrSizeRestrictionRule"
  metric_name = "${var.name}wafrSizeRestrictionRule"

  predicates {
    data_id = "${aws_waf_size_constraint_set.wafgSizeRestrictionSet.id}"
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_waf_size_constraint_set" "wafgSizeRestrictionSet" {
  name = "${var.name}wafgSizeRestrictionSet"

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
