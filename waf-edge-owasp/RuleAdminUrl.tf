# N/A - No Adin URL
# https://github.com/awslabs/aws-waf-sample/blob/master/waf-owasp-top-10/owasp_10_base.yml#L514

resource "aws_waf_ipset" "adminlist" {
  name = "${var.name}-adminlist-ipset"
}

resource "aws_waf_rule" "wafAdminAccessRule" {
  depends_on = [
    "aws_waf_byte_match_set.wafAdminUrlStringSet",
  ]

  name        = "${local.name}wafAdminAccessRule"
  metric_name = "${local.name}wafAdminAccessRule"

  predicates {
    data_id = "${aws_waf_byte_match_set.wafAdminUrlStringSet.id}"
    negated = false
    type    = "ByteMatch"
  }

  predicates {
    data_id = "${var.ipAdminlistId != "" ? var.ipAdminlistId : aws_waf_ipset.adminlist.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_byte_match_set" "wafAdminUrlStringSet" {
  name = "${local.name}wafAdminUrlStringSet"

  // TODO N/A
  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "${var.adminUrlPrefix}"
    positional_constraint = "STARTS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}
