resource "aws_waf_rule" "wafrXSSRule" {
  depends_on = [
    "aws_waf_xss_match_set.wafrXSSSet",
  ]

  name        = "${local.name}wafrXSSRule"
  metric_name = "${local.name}wafrXSSRule"

  predicates {
    data_id = "${aws_waf_xss_match_set.wafrXSSSet.id}"
    negated = false
    type    = "XssMatch"
  }
}

resource "aws_waf_xss_match_set" "wafrXSSSet" {
  name = "${local.name}wafrXSSSet"

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
