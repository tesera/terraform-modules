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

  rule {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = "${aws_wafregional_rule.wafrSizeRestrictionRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = "${aws_wafregional_rule.wafgIpBlackListRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 30
    rule_id  = "${aws_wafregional_rule.wafgAuthTokenRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 40
    rule_id  = "${aws_wafregional_rule.wafgSQLiRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 50
    rule_id  = "${aws_wafregional_rule.wafrXSSRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 60
    rule_id  = "${aws_wafregional_rule.wafgPathsRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 80
    rule_id  = "${aws_wafregional_rule.wafgCSRFRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 90
    rule_id  = "${aws_wafregional_rule.wafgServerSideIncludeRule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 100
    rule_id  = "${aws_wafregional_rule.wafgAdminAccessRule.id}"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 999
    rule_id  = "${aws_wafregional_rule.wafgIpWhiteListRule.id}"
  }
}
