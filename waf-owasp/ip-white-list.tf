
resource "aws_waf_rule" "wafgIpWhiteListRule" {
  name        = "${var.name}wafgIpWhiteListRule"
  metric_name = "${var.name}wafgIpWhiteListRule"

  predicates {
    data_id = "${local.ipset_white_id}"
    negated = false
    type    = "IPMatch"
  }
}

