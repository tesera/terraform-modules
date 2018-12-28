resource "aws_wafregional_web_acl" "wafrOwaspACL" {
  depends_on = [
    "aws_wafregional_rule.wafgAdminAccessRule",
    "aws_wafregional_rule.wafgAuthTokenRule",
    "aws_wafregional_rule.wafgCSRFRule",
    "aws_wafregional_rule.wafgPathsRule",
    "aws_wafregional_rule.wafgServerSideIncludeRule",
    "aws_wafregional_rule.wafrXSSRule",
    "aws_wafregional_rule.wafgIpBlackListRule",
    "aws_wafregional_rule.wafgIpWhiteListRule",
  ]

  name        = "${local.name}wafrOwaspACL"
  metric_name = "${local.name}wafrOwaspACL"

  default_action {
    type = "${var.defaultAction}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = "${aws_wafregional_rule.wafrSizeRestrictionRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_wafregional_rule.wafgIpBlackListRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = "${aws_wafregional_rule.wafgAuthTokenRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_wafregional_rule.wafgSQLiRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_wafregional_rule.wafrXSSRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_wafregional_rule.wafgPathsRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_wafregional_rule.wafgCSRFRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 90
    rule_id  = "${aws_wafregional_rule.wafgServerSideIncludeRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 100
    rule_id  = "${aws_wafregional_rule.wafgAdminAccessRule.id}"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 999
    rule_id  = "${aws_wafregional_rule.wafgIpWhiteListRule.id}"
  }
}
