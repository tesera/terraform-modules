# https://www.terraform.io/docs/providers/aws/r/waf_rate_based_rule.html

resource "aws_waf_rate_based_rule" "wafHTTPFloodRule" {
  count       = var.type != "regional" ? 1 : 0
  depends_on  = [aws_waf_ipset.http-flood]
  name        = "${local.name}wafHTTPFloodRule"
  metric_name = "wafHTTPFloodRule"

  rate_key   = "IP"
  rate_limit = var.requestThreshold # per 5min

  predicates {
    data_id = aws_waf_ipset.http-flood[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "http-flood" {
  count = var.type != "regional" ? 1 : 0
  name  = "${var.name}-http-flood-ipset"
}

# Regional
resource "aws_wafregional_rate_based_rule" "wafHTTPFloodRule" {
  count       = var.type == "regional" ? 1 : 0
  depends_on  = [aws_wafregional_ipset.http-flood]
  name        = "${local.name}wafRegionalHTTPFloodRule"
  metric_name = "wafRegionalHTTPFloodRule"

  rate_key   = "IP"
  rate_limit = var.requestThreshold # per 5min

  predicate {
    data_id = aws_wafregional_ipset.http-flood[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "http-flood" {
  count = var.type == "regional" ? 1 : 0
  name  = "${var.name}-http-flood-regional-ipset"
}

