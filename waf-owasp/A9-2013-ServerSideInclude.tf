resource "aws_waf_rule" "wafgServerSideIncludeRule" {
  depends_on = [
    "aws_waf_byte_match_set.wafgServerSideIncludeStringSet",
  ]

  name        = "${local.name}wafgServerSideIncludeRule"
  metric_name = "${local.name}wafgServerSideIncludeRule"

  predicates {
    data_id = "${aws_waf_byte_match_set.wafgServerSideIncludeStringSet.id}"
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_waf_byte_match_set" "wafgServerSideIncludeStringSet" {
  name = "${local.name}wafgServerSideIncludeStringSet"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "${var.includesPrefix}"
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
