resource "aws_waf_web_acl" "wafrOwaspACL" {
  depends_on = [
    "aws_waf_rule.wafgAdminAccessRule",
    "aws_waf_rule.wafgAuthTokenRule",
    "aws_waf_rule.wafgCSRFRule",
    "aws_waf_rule.wafgPathsRule",
    "aws_waf_rule.wafgServerSideIncludeRule",
    "aws_waf_rule.wafrXSSRule",
    "aws_waf_rule.wafgIpBlackListRule",
    "aws_waf_rule.wafgIpWhiteListRule",
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
    rule_id  = "${aws_waf_rule.wafrSizeRestrictionRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_waf_rule.wafgIpBlackListRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = "${aws_waf_rule.wafgAuthTokenRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_waf_rule.wafgSQLiRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_waf_rule.wafrXSSRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_waf_rule.wafgPathsRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_waf_rule.wafgCSRFRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 90
    rule_id  = "${aws_waf_rule.wafgServerSideIncludeRule.id}"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 100
    rule_id  = "${aws_waf_rule.wafgAdminAccessRule.id}"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 999
    rule_id  = "${aws_waf_rule.wafgIpWhiteListRule.id}"
  }
}
