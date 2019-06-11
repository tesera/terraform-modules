# OWASP A1-2017

resource "aws_waf_rule" "wafgSQLInjectionRule" {
  depends_on = [
    "aws_waf_sql_injection_match_set.wafrSQLInjectionSet",
  ]

  name        = "${local.name}wafgSQLInjectionRule"
  metric_name = "${local.name}wafgSQLInjectionRule"

  predicates {
    data_id = "${aws_waf_sql_injection_match_set.wafrSQLInjectionSet.id}"
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_waf_sql_injection_match_set" "wafrSQLInjectionSet" {
  name = "${local.name}wafrSQLInjectionSet"

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}
