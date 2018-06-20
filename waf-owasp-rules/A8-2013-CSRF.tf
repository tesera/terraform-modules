resource "aws_waf_rule" "wafgCSRFRule" {
  depends_on = [
    "aws_waf_byte_match_set.wafgCSRFMethodStringSet",
    "aws_waf_size_constraint_set.wafgCSRFTokenSizeConstraint",
  ]

  name        = "${var.name}wafgCSRFRule"
  metric_name = "${var.name}wafgCSRFRule"

  predicates {
    data_id = "${aws_waf_byte_match_set.wafgCSRFMethodStringSet.id}"
    negated = false
    type    = "ByteMatch"
  }

  predicates {
    data_id = "${aws_waf_size_constraint_set.wafgCSRFTokenSizeConstraint.id}"
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_waf_byte_match_set" "wafgCSRFMethodStringSet" {
  name = "${var.name}wafgCSRFMethodStringSet"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "post"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "METHOD"
    }
  }
}

resource "aws_waf_size_constraint_set" "wafgCSRFTokenSizeConstraint" {
  name = "${var.name}wafgCSRFTokenSizeConstraint"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size                = "${var.csrfExpectedSize}"

    field_to_match {
      type = "HEADER"
      data = "${var.csrfExpectedHeader}"
    }
  }
}
