resource "aws_wafregional_rule" "wafgIpWhiteListRule" {
  name        = "${local.name}wafgIpWhiteListRule"
  metric_name = "${local.name}wafgIpWhiteListRule"

  predicate {
    data_id = local.ipset_white_id
    negated = false
    type    = "IPMatch"
  }
}

