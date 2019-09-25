resource "aws_waf_rule_group" "wafBlacklistRuleGroup" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_rule.wafBlacklistRule,
    aws_waf_rule.wafBadBotRule,
    aws_waf_rule.wafScannerProbesRule,
    aws_waf_rule.wafReputationListRule,
    aws_waf_rate_based_rule.wafHTTPFloodRule,
  ]
  metric_name = "${local.name}wafBlacklistRuleGroup"
  name        = "${local.name}wafBlacklistRuleGroup"

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = aws_waf_rule.wafBlacklistRule[0].id
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = aws_waf_rule.wafBadBotRule[0].id
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = aws_waf_rule.wafScannerProbesRule[0].id
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = aws_waf_rule.wafReputationListRule[0].id
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = aws_waf_rate_based_rule.wafHTTPFloodRule[0].id
    type     = "RATE_BASED"
  }
}

# Regional
resource "aws_wafregional_rule_group" "wafBlacklistRuleGroup" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_rule.wafBlacklistRule,
    aws_wafregional_rule.wafBadBotRule,
    aws_wafregional_rule.wafScannerProbesRule,
    aws_wafregional_rule.wafReputationListRule,
    aws_wafregional_rate_based_rule.wafHTTPFloodRule,
  ]
  metric_name = "${local.name}wafRegionalBlacklistRuleGroup"
  name        = "${local.name}wafRegionalBlacklistRuleGroup"

  activated_rule {
    priority = 10
    rule_id  = aws_wafregional_rule.wafBlacklistRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 20
    rule_id  = aws_wafregional_rule.wafBadBotRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 30
    rule_id  = aws_wafregional_rule.wafScannerProbesRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 40
    rule_id  = aws_wafregional_rule.wafReputationListRule[0].id
    action {
      type = "BLOCK"
    }
  }

  // Terraform issue
  //  activated_rule {
  //    priority = 50
  //    rule_id  = aws_wafregional_rate_based_rule.wafHTTPFloodRule[0].id
  //    type = "RATE_BASED"
  //    action {
  //      type = "BLOCK"
  //    }
  //  }
}
