# N/A no Auth tokens
# https://github.com/awslabs/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml#L244

resource "aws_waf_rule" "wafAuthTokenRule" {
  count      = var.type != "regional" ? 1 : 0
  depends_on = [aws_waf_byte_match_set.wafAuthTokenStringSet]

  name        = "${local.name}wafAuthTokenRule"
  metric_name = "${local.name}wafAuthTokenRule"

  predicates {
    data_id = aws_waf_byte_match_set.wafAuthTokenStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_waf_byte_match_set" "wafAuthTokenStringSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafAuthTokenStringSet"

  # TODO replace with real examples
  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "example-session-id"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }
}

# Regional
resource "aws_wafregional_rule" "wafAuthTokenRule" {
  count      = var.type == "regional" ? 1 : 0
  depends_on = [aws_wafregional_byte_match_set.wafAuthTokenStringSet]

  name        = "${local.name}wafRegionalAuthTokenRule"
  metric_name = "${local.name}wafRegionalAuthTokenRule"

  predicate {
    data_id = aws_wafregional_byte_match_set.wafAuthTokenStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_wafregional_byte_match_set" "wafAuthTokenStringSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalAuthTokenStringSet"

  # TODO replace with real examples
  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "example-session-id"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }
}

