# https://www.terraform.io/docs/providers/aws/r/waf_rate_based_rule.html
resource "aws_wafregional_rate_based_rule" "wafHTTPFloodRule" {
  name        = "${local.name}wafHTTPFlood"
  metric_name = "wafHTTPFlood"

  rate_key   = "IP"
  rate_limit = var.rateLimit # per 5min
}

