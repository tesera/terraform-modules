resource "aws_waf_ipset" "whitelist" {
  name = "${var.name}-whitelist-ipset"
}

resource "aws_waf_rule" "wafWhitelistRule" {
  name        = "${local.name}wafWhitelistRule"
  metric_name = "${local.name}wafWhitelistRule"

  predicates {
    data_id = var.ipWhitelistId != "" ? var.ipWhitelistId : aws_waf_ipset.whitelist.id
    negated = false
    type    = "IPMatch"
  }
}

