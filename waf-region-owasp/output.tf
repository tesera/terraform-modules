output "id" {
  value = (var.type == "regional" ? aws_wafregional_web_acl.wafACL[0].id : aws_waf_web_acl.wafACL[0].id)
}

output "ipset_bad-bot_arn" {
  value = (var.type == "regional" ? aws_wafregional_ipset.bad-bot[0].arn : aws_waf_ipset.bad-bot[0].arn)
}

output "ipset_bad-bot_id" {
  value = (var.type == "regional" ? aws_wafregional_ipset.bad-bot[0].id : aws_waf_ipset.bad-bot[0].id)
}

