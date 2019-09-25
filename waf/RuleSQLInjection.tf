# OWASP A1-2017

resource "aws_waf_rule" "wafSQLInjectionRule" {
  count      = var.type != "regional" ? 1 : 0
  depends_on = [aws_waf_sql_injection_match_set.wafSQLInjectionSet]

  name        = "${local.name}wafSQLInjectionRule"
  metric_name = "${local.name}wafSQLInjectionRule"

  predicates {
    data_id = aws_waf_sql_injection_match_set.wafSQLInjectionSet[0].id
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_waf_sql_injection_match_set" "wafSQLInjectionSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafSQLInjectionSet"

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

# Regional
resource "aws_wafregional_rule" "wafSQLInjectionRule" {
  count      = var.type == "regional" ? 1 : 0
  depends_on = [aws_wafregional_sql_injection_match_set.wafSQLInjectionRuleSet]

  name        = "${local.name}wafRegionalSQLInjectionRule"
  metric_name = "${local.name}wafRegionalSQLInjectionRule"

  predicate {
    data_id = aws_wafregional_sql_injection_match_set.wafSQLInjectionRuleSet[0].id
    negated = false
    type    = "SqlInjectionMatch"
  }
}

resource "aws_wafregional_sql_injection_match_set" "wafSQLInjectionRuleSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalSQLInjectionRuleSet"

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }
}

