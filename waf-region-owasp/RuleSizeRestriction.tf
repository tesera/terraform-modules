resource "aws_waf_rule" "wafSizeRestrictionRule" {
  count      = var.type != "regional" ? 1 : 0
  depends_on = [aws_waf_size_constraint_set.wafSizeRestrictionSet]

  name        = "${local.name}wafSizeRestrictionRule"
  metric_name = "${local.name}wafSizeRestrictionRule"

  predicates {
    data_id = aws_waf_size_constraint_set.wafSizeRestrictionSet[0].id
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_waf_size_constraint_set" "wafSizeRestrictionSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafSizeRestrictionSet"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedURISize

    field_to_match {
      type = "URI"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedQueryStringSize

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedBodySize

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedCookieSize

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

# Regional
resource "aws_wafregional_rule" "wafSizeRestrictionRule" {
  count      = var.type == "regional" ? 1 : 0
  depends_on = [aws_wafregional_size_constraint_set.wafSizeRestrictionSet]

  name        = "${local.name}wafRegionalSizeRestrictionRule"
  metric_name = "${local.name}wafRegionalSizeRestrictionRule"

  predicate {
    data_id = aws_wafregional_size_constraint_set.wafSizeRestrictionSet[0].id
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_wafregional_size_constraint_set" "wafSizeRestrictionSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalSizeRestrictionSet"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedURISize

    field_to_match {
      type = "URI"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedQueryStringSize

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedBodySize

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = var.maxExpectedCookieSize

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

