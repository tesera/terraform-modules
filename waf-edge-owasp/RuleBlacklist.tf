
## Blacklist
resource "aws_waf_ipset" "blacklist" {
  name = "${var.name}-blacklist-ipset"
}
resource "aws_waf_rule" "wafBlacklistRule" {
  depends_on  = [
    "aws_waf_ipset.blacklist",
    "aws_waf_ipset.bad-bot",
    "aws_waf_ipset.scanners-probes",
    "aws_waf_ipset.reputation-list"
  ]
  name        = "${local.name}wafBlacklistRule"
  metric_name = "${local.name}wafBlacklistRule"

  predicates {
    data_id = "${aws_waf_ipset.blacklist.id}"
    negated = false
    type    = "IPMatch"
  }

  predicates {
    data_id = "${aws_waf_ipset.bad-bot.id}"
    negated = false
    type    = "IPMatch"
  }

  predicates {
    data_id = "${aws_waf_ipset.scanners-probes.id}"
    negated = false
    type    = "IPMatch"
  }

  predicates {
    data_id = "${aws_waf_ipset.reputation-list.id}"
    negated = false
    type    = "IPMatch"
  }
}

## Bad Bot
resource "aws_waf_ipset" "bad-bot" {
  name = "${var.name}-bad-bot-ipset"
}

//resource "aws_waf_rule" "wafBadBotRule" {
//  name        = "${local.name}wafBadBotRule"
//  metric_name = "${local.name}wafBadBotRule"
//
//  predicates {
//    data_id = "${aws_waf_ipset.bad-bot.id}"
//    negated = false
//    type    = "IPMatch"
//  }
//}

## Scanners & Probes
resource "aws_waf_ipset" "scanners-probes" {
  name = "${var.name}-scanners-probes-ipset"
}

//resource "aws_waf_rule" "wafScannersProbesRule" {
//  name        = "${local.name}wafScannersProbesRule"
//  metric_name = "${local.name}wafScannersProbesRule"
//
//  predicates {
//    data_id = "${aws_waf_ipset.scanners-probes.id}"
//    negated = false
//    type    = "IPMatch"
//  }
//}

## Reputation List
resource "aws_waf_ipset" "reputation-list" {
  name = "${var.name}-reputation-list-ipset"
}

//resource "aws_waf_rule" "wafReputationListRule" {
//  name        = "${local.name}wafReputationListRule"
//  metric_name = "${local.name}wafReputationListRule"
//
//  predicates {
//    data_id = "${aws_waf_ipset.reputation-list.id}"
//    negated = false
//    type    = "IPMatch"
//  }
//}
