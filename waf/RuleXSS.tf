resource "aws_waf_rule" "wafXSSRule" {
  count      = var.type != "regional" ? 1 : 0
  depends_on = [aws_waf_xss_match_set.wafXSSSet]

  name        = "${local.name}wafXSSRule"
  metric_name = "${local.name}wafXSSRule"

  predicates {
    data_id = aws_waf_xss_match_set.wafXSSSet[0].id
    negated = false
    type    = "XssMatch"
  }
}

resource "aws_waf_xss_match_set" "wafXSSSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafXSSSet"

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

# Regional
resource "aws_wafregional_rule" "wafXSSRule" {
  count      = var.type == "regional" ? 1 : 0
  depends_on = [aws_wafregional_xss_match_set.wafXSSSet]

  name        = "${local.name}wafRegionalXSSRule"
  metric_name = "${local.name}wafRegionalXSSRule"

  predicate {
    data_id = aws_wafregional_xss_match_set.wafXSSSet[0].id
    negated = false
    type    = "XssMatch"
  }
}

resource "aws_wafregional_xss_match_set" "wafXSSSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalXSSSet"

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

