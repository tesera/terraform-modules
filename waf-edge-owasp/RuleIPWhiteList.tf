resource "aws_waf_rule" "wafgIpWhiteListRule" {
  name        = "${local.name}wafgIpWhiteListRule"
  metric_name = "${local.name}wafgIpWhiteListRule"

  predicates {
    data_id = "${local.ipset_white_id}"
    negated = false
    type    = "IPMatch"
  }
}
