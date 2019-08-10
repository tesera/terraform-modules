# OWASP A1-2017

resource "aws_waf_rule" "wafSQLInjectionRule" {
  depends_on = [aws_waf_sql_injection_match_set.wafSQLInjectionSet]

  name        = "${local.name}wafSQLInjectionRule"
  metric_name = "${local.name}wafSQLInjectionRule"

  predicates {
    data_id = aws_waf_sql_injection_match_set.wafSQLInjectionSet.id
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_waf_sql_injection_match_set" "wafSQLInjectionSet" {
  name = "${local.name}wafSQLInjectionSet"

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

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }
}

