resource "aws_waf_rule" "wafgIpBlackListRule" {
  name        = "${local.name}wafgIpBlackListRule"
  metric_name = "${local.name}wafgIpBlackListRule"

  predicates {
    data_id = "${local.ipset_black_id}"
    negated = false
    type    = "IPMatch"
  }
}
