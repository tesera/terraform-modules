resource "aws_waf_rule" "wafCSRFRule" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_byte_match_set.wafCSRFMethodStringSet,
    aws_waf_size_constraint_set.wafCSRFTokenSizeConstraint,
  ]

  name        = "${local.name}wafCSRFRule"
  metric_name = "${local.name}wafCSRFRule"

  predicates {
    data_id = aws_waf_byte_match_set.wafCSRFMethodStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }

  predicates {
    data_id = aws_waf_size_constraint_set.wafCSRFTokenSizeConstraint[0].id
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_waf_byte_match_set" "wafCSRFMethodStringSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafCSRFMethodStringSet"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "post"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "METHOD"
    }
  }
}

resource "aws_waf_size_constraint_set" "wafCSRFTokenSizeConstraint" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafCSRFTokenSizeConstraint"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size                = var.csrfExpectedSize

    field_to_match {
      type = "HEADER"
      data = var.csrfExpectedHeader
    }
  }
}

# Regional
resource "aws_wafregional_rule" "wafCSRFRule" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_byte_match_set.wafCSRFMethodStringSet,
    aws_wafregional_size_constraint_set.wafCSRFTokenSizeConstraint,
  ]

  name        = "${local.name}wafRegionalCSRFRule"
  metric_name = "${local.name}wafRegionalCSRFRule"

  predicate {
    data_id = aws_wafregional_byte_match_set.wafCSRFMethodStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = aws_wafregional_size_constraint_set.wafCSRFTokenSizeConstraint[0].id
    negated = false
    type    = "SizeConstraint"
  }
}

resource "aws_wafregional_byte_match_set" "wafCSRFMethodStringSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalCSRFMethodStringSet"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "post"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "METHOD"
    }
  }
}

resource "aws_wafregional_size_constraint_set" "wafCSRFTokenSizeConstraint" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalCSRFTokenSizeConstraint"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size                = var.csrfExpectedSize

    field_to_match {
      type = "HEADER"
      data = var.csrfExpectedHeader
    }
  }
}

