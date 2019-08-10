resource "aws_wafregional_rule" "wafgIpBlackListRule" {
  name        = "${local.name}wafgIpBlackListRule"
  metric_name = "${local.name}wafgIpBlackListRule"

  predicate {
    data_id = local.ipset_black_id
    negated = false
    type    = "IPMatch"
  }
}

