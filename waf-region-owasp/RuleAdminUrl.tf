# N/A - No Adin URL
# https://github.com/awslabs/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml#L514

resource "aws_wafregional_rule" "wafgAdminAccessRule" {
  depends_on = [aws_wafregional_byte_match_set.wafrAdminUrlStringSet]

  name        = "${local.name}wafgAdminAccessRule"
  metric_name = "${local.name}wafgAdminAccessRule"

  predicate {
    data_id = aws_wafregional_byte_match_set.wafrAdminUrlStringSet.id
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = local.ipset_admin_id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_byte_match_set" "wafrAdminUrlStringSet" {
  name = "${local.name}wafrAdminUrlStringSet"

  // TODO N/A
  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = var.adminUrlPrefix
    positional_constraint = "STARTS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

