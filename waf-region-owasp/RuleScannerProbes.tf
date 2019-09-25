## Blacklists

resource "aws_waf_rule" "wafScannerProbesRule" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_ipset.scanners-probes,
  ]
  name        = "${local.name}wafScannerProbesRule"
  metric_name = "${local.name}wafScannerProbesRule"


  predicates {
    data_id = aws_waf_ipset.scanners-probes[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "scanners-probes" {
  count = var.type != "regional" ? 1 : 0
  name  = "${var.name}-scanners-probes-ipset"
}

# Regional
resource "aws_wafregional_rule" "wafScannerProbesRule" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_ipset.blacklist,
    aws_wafregional_ipset.bad-bot,
    aws_wafregional_ipset.scanners-probes,
    aws_wafregional_ipset.reputation-list,
  ]
  name        = "${local.name}wafRegionalScannerProbesRule"
  metric_name = "${local.name}wafRegionalScannerProbesRule"

  predicate {
    data_id = aws_wafregional_ipset.scanners-probes[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "scanners-probes" {
  count = var.type == "regional" ? 1 : 0
  name  = "${var.name}-scanners-probes-regional-ipset"
}
