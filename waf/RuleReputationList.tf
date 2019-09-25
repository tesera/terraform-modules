## Blacklists

resource "aws_waf_rule" "wafReputationListRule" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_ipset.reputation-list,
  ]
  name        = "${local.name}wafReputationListRule"
  metric_name = "${local.name}wafReputationListRule"

  predicates {
    data_id = aws_waf_ipset.reputation-list[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "reputation-list" {
  count = var.type != "regional" ? 1 : 0
  name  = "${var.name}-reputation-list-ipset"
}

# Regional
resource "aws_wafregional_rule" "wafReputationListRule" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_ipset.blacklist,
    aws_wafregional_ipset.bad-bot,
    aws_wafregional_ipset.scanners-probes,
    aws_wafregional_ipset.reputation-list,
  ]
  name        = "${local.name}wafRegionalReputationListRule"
  metric_name = "${local.name}wafRegionalReputationListRule"

  predicate {
    data_id = aws_wafregional_ipset.reputation-list[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "reputation-list" {
  count = var.type == "regional" ? 1 : 0
  name  = "${var.name}-reputation-list-regional-ipset"
}

