resource "aws_waf_rule" "wafXSSRule" {
  depends_on = [
    "aws_waf_xss_match_set.wafXSSSet",
  ]

  name        = "${local.name}wafXSSRule"
  metric_name = "${local.name}wafXSSRule"

  predicates {
    data_id = "${aws_waf_xss_match_set.wafXSSSet.id}"
    negated = false
    type    = "XssMatch"
  }
}

resource "aws_waf_xss_match_set" "wafXSSSet" {
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
