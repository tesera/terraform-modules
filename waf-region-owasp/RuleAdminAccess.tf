# N/A - No Adin URL
# https://github.com/awslabs/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml#L514



resource "aws_waf_rule" "wafAdminAccessRule" {
  count      = var.type != "regional" ? 1 : 0
  depends_on = [aws_waf_byte_match_set.wafAdminUrlStringSet]

  name        = "${local.name}wafAdminAccessRule"
  metric_name = "${local.name}wafAdminAccessRule"

  predicates {
    data_id = aws_waf_byte_match_set.wafAdminUrlStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }

  predicates {
    data_id = var.ipAdminlistId != "" ? var.ipAdminlistId : aws_waf_ipset.adminlist[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "adminlist" {
  count = var.type != "regional" ? 1 : 0
  name  = "${var.name}-adminlist-ipset"
}

resource "aws_waf_byte_match_set" "wafAdminUrlStringSet" {
  count = var.type != "regional" ? 1 : 0
  name  = "${local.name}wafAdminUrlStringSet"

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


# N/A - No Adin URL
# https://github.com/awslabs/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml#L514

resource "aws_wafregional_rule" "wafAdminAccessRule" {
  count      = var.type == "regional" ? 1 : 0
  depends_on = [aws_wafregional_byte_match_set.wafAdminUrlStringSet]

  name        = "${local.name}wafRegionalAdminAccessRule"
  metric_name = "${local.name}wafRegionalAdminAccessRule"

  predicate {
    data_id = aws_wafregional_byte_match_set.wafAdminUrlStringSet[0].id
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = var.ipAdminlistId != "" ? var.ipAdminlistId : aws_wafregional_ipset.adminlist[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "adminlist" {
  count = var.type == "regional" ? 1 : 0
  name  = "${var.name}-adminlist-regional-ipset"
}

resource "aws_wafregional_byte_match_set" "wafAdminUrlStringSet" {
  count = var.type == "regional" ? 1 : 0
  name  = "${local.name}wafRegionalAdminAccessRuleSet"

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

