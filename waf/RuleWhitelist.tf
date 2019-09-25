resource "aws_waf_rule" "wafWhitelistRule" {
  count       = var.type != "regional" ? 1 : 0
  name        = "${local.name}wafWhitelistRule"
  metric_name = "${local.name}wafWhitelistRule"

  predicates {
    data_id = var.ipWhitelistId != "" ? var.ipWhitelistId : aws_waf_ipset.whitelist[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "whitelist" {
  count = var.type != "regional" ? 1 : 0
  name  = "${var.name}-whitelist-ipset"
}

resource "aws_wafregional_rule" "wafWhitelistRule" {
  count       = var.type == "regional" ? 1 : 0
  name        = "${local.name}wafRegionalWhitelistRule"
  metric_name = "${local.name}wafRegionalWhitelistRule"

  predicate {
    data_id = var.ipWhitelistId != "" ? var.ipWhitelistId : aws_wafregional_ipset.whitelist[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "whitelist" {
  count = var.type == "regional" ? 1 : 0
  name  = "${var.name}-whitelist-regional-ipset"
}

