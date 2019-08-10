output "id" {
  value = aws_waf_web_acl.wafOwaspACL.id
}

output "ipset_bad-bot_arn" {
  value = aws_waf_ipset.bad-bot.id
}

output "ipset_bad-bot_id" {
  value = aws_waf_ipset.bad-bot.id
}

