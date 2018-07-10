resource "aws_waf_rule" "wafgSQLiRule" {
  depends_on = [
    "aws_waf_sql_injection_match_set.wafrSQLiSet",
  ]

  name        = "${local.name}wafgSQLiRule"
  metric_name = "${local.name}wafgSQLiRule"

  predicates {
    data_id = "${aws_waf_sql_injection_match_set.wafrSQLiSet.id}"
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_waf_sql_injection_match_set" "wafrSQLiSet" {
  name = "${local.name}wafrSQLiSet"

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
