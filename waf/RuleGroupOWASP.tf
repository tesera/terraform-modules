resource "aws_waf_rule_group" "wafOWASPRuleGroup" {
  count = var.type != "regional" ? 1 : 0
  depends_on = [
    aws_waf_rule.wafSQLInjectionRule,
    aws_waf_rule.wafXSSRule,
    aws_waf_rule.wafAdminAccessRule,
    aws_waf_rule.wafAuthTokenRule,
    aws_waf_rule.wafCSRFRule,
    aws_waf_rule.wafPathsRule,
    aws_waf_rule.wafServerSideIncludeRule,
    aws_waf_rule.wafAdminAccessRule,
  ]
  metric_name = "${local.name}wafOWASPRuleGroup"
  name        = "${local.name}wafOWASPRuleGroup"

  activated_rule {
    priority = 1
    rule_id  = aws_waf_rule.wafSizeRestrictionRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 2
    rule_id  = aws_waf_rule.wafAuthTokenRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 3
    rule_id  = aws_waf_rule.wafSQLInjectionRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 4
    rule_id  = aws_waf_rule.wafXSSRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 5
    rule_id  = aws_waf_rule.wafPathsRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 6
    rule_id  = aws_waf_rule.wafCSRFRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 7
    rule_id  = aws_waf_rule.wafServerSideIncludeRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 8
    rule_id  = aws_waf_rule.wafAdminAccessRule[0].id
    action {
      type = "BLOCK"
    }
  }
}

# Regional
resource "aws_wafregional_rule_group" "wafOWASPRuleGroup" {
  count = var.type == "regional" ? 1 : 0
  depends_on = [
    aws_wafregional_rule.wafSQLInjectionRule,
    aws_wafregional_rule.wafXSSRule,
    aws_wafregional_rule.wafAdminAccessRule,
    aws_wafregional_rule.wafAuthTokenRule,
    aws_wafregional_rule.wafCSRFRule,
    aws_wafregional_rule.wafPathsRule,
    aws_wafregional_rule.wafServerSideIncludeRule,
    aws_wafregional_rule.wafAdminAccessRule,
  ]
  metric_name = "${local.name}wafRegionalOWASPRuleGroup"
  name        = "${local.name}wafRegionalOWASPRuleGroup"

  activated_rule {
    priority = 1
    rule_id  = aws_wafregional_rule.wafSizeRestrictionRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 2
    rule_id  = aws_wafregional_rule.wafAuthTokenRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 3
    rule_id  = aws_wafregional_rule.wafSQLInjectionRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 4
    rule_id  = aws_wafregional_rule.wafXSSRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 5
    rule_id  = aws_wafregional_rule.wafPathsRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 6
    rule_id  = aws_wafregional_rule.wafCSRFRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 7
    rule_id  = aws_wafregional_rule.wafServerSideIncludeRule[0].id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 8
    rule_id  = aws_wafregional_rule.wafAdminAccessRule[0].id
    action {
      type = "BLOCK"
    }
  }
}
