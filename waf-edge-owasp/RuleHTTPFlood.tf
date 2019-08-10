# https://www.terraform.io/docs/providers/aws/r/waf_rate_based_rule.html

resource "aws_waf_ipset" "http-flood" {
  name = "${var.name}-http-flood-ipset"
}

resource "aws_waf_rate_based_rule" "wafHTTPFloodRule" {
  depends_on  = [aws_waf_ipset.http-flood]
  name        = "${local.name}wafHTTPFloodRule"
  metric_name = "wafHTTPFloodRule"

  rate_key   = "IP"
  rate_limit = var.requestThreshold # per 5min

  predicates {
    data_id = aws_waf_ipset.http-flood.id
    negated = false
    type    = "IPMatch"
  }
}

