resource "aws_waf_rule" "wafgIpBlackListRule" {
  name        = "${var.name}wafgIpBlackListRule"
  metric_name = "${var.name}wafgIpBlackListRule"

  predicates {
    data_id = "${local.ipset_black_id}"
    negated = false
    type    = "IPMatch"
  }
}
