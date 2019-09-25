resource "aws_waf_rule" "wafServerSideIncludeRule" {
  count      = var.type != "regional" ? 1 : 0
  depends_on = [aws_waf_byte_match_set.wafServerSideIncludeStringSet]

  name        = "${local.name}wafServerSideIncludeRule"
  metric_name = "${local.name}wafServerSideIncludeRule"

  predicates {
    data_id = aws_waf_byte_match_set.wafServerSideIncludeStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_waf_byte_match_set" "wafServerSideIncludeStringSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafServerSideIncludeStringSet"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = var.includesPrefix
    positional_constraint = "STARTS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".cfg"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".conf"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".ini"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".log"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".bak"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".backup"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

# Regional
resource "aws_wafregional_rule" "wafServerSideIncludeRule" {
  count      = var.type == "regional" ? 1 : 0
  depends_on = [aws_wafregional_byte_match_set.wafServerSideIncludeStringSet]

  name        = "${local.name}wafRegionalServerSideIncludeRule"
  metric_name = "${local.name}wafRegionalServerSideIncludeRule"

  predicate {
    data_id = aws_wafregional_byte_match_set.wafServerSideIncludeStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_wafregional_byte_match_set" "wafServerSideIncludeStringSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalServerSideIncludeStringSet"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = var.includesPrefix
    positional_constraint = "STARTS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".cfg"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".conf"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".ini"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".log"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".bak"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".backup"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

