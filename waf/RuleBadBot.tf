resource "aws_waf_rule" "wafBadBotRule" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_ipset.bad-bot,
  ]
  name        = "${local.name}wafBadBotRule"
  metric_name = "${local.name}wafBadBotRule"

  predicates {
    data_id = aws_waf_ipset.bad-bot[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "bad-bot" {
  count = var.type != "regional" ? 1 : 0
  name  = "${var.name}-bad-bot-ipset"
}

# Regional
resource "aws_wafregional_rule" "wafBadBotRule" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_ipset.bad-bot,
  ]
  name        = "${local.name}wafRegionalBlacklistRule"
  metric_name = "${local.name}wafRegionalBlacklistRule"

  predicate {
    data_id = aws_wafregional_ipset.bad-bot[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "bad-bot" {
  count = var.type == "regional" ? 1 : 0
  name  = "${var.name}-bad-bot-regional-ipset"
}
