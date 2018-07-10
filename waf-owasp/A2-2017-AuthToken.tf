# N/A no Auth tokens
# https://github.com/awslabs/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml#L244

resource "aws_waf_rule" "wafgAuthTokenRule" {
  depends_on = [
    "aws_waf_byte_match_set.wafrAuthTokenStringSet",
  ]

  name        = "${local.name}wafgAuthTokenRule"
  metric_name = "${local.name}wafgAuthTokenRule"

  predicates {
    data_id = "${aws_waf_byte_match_set.wafrAuthTokenStringSet.id}"
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_waf_byte_match_set" "wafrAuthTokenStringSet" {
  name = "${local.name}wafrAuthTokenStringSet"

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
