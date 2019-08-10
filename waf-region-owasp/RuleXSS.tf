resource "aws_wafregional_rule" "wafrXSSRule" {
  depends_on = [aws_wafregional_xss_match_set.wafrXSSSet]

  name        = "${local.name}wafrXSSRule"
  metric_name = "${local.name}wafrXSSRule"

  predicate {
    data_id = aws_wafregional_xss_match_set.wafrXSSSet.id
    negated = false
    type    = "XssMatch"
  }
}

resource "aws_wafregional_xss_match_set" "wafrXSSSet" {
  name = "${local.name}wafrXSSSet"

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

