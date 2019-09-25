# Web Application Firewall (WAF)
To be used with CloudFront, ALB, API Gateway.

## Setup

### Module
```hcl-terraform

module "waf_cdn" {
  source        = "./modules/waf"
  type          = "edge"
  name          = "${local.workspace["name"]}"
  defaultAction = "${var.defaultAction}"

  ipAdminListId = "${aws_waf_ipset.admin.id}"
  ipWhiteListId = "${aws_waf_ipset.white.id}"
  
  logging_bucket = "${local.workspace["name"]}-${local.workspace["env"]}-edge-logs"
  
  providers = {
    aws = "aws.edge"
  }
}

module "waf_alb" {
  source        = "./modules/waf"
  type          = "regional"
  name          = "${local.workspace["name"]}"
  defaultAction = "${var.defaultAction}"

  ipAdminListId = "${aws_wafregional_ipset.admin.id}"
  ipWhiteListId = "${aws_wafregional_ipset.white.id}"
  
  logging_bucket = "${local.workspace["name"]}-${local.workspace["env"]}-${local.workspace["region"]}-logs"
}


resource "aws_ssm_parameter" "bad-bot" {
  name        = "/config/waf/ipset/bad-bot"
  description = "IP Set ID of the bad bot / honeypot blacklist"
  type        = "SecureString"
  value       = "${module.waf.ipset_bad-bot_id}"
}

```

### IP Lists
```hcl-terraform
resource "aws_waf_ipset" "white" {
  name = "${var.name}-override-white-ipset"
}

resource "aws_wafregional_ipset" "white" {
  name = "${var.name}-override-white-ipset"
}

```

## Input
- **type:** Type of WAF. `regional` or `edge`. [Default: `edge`]
- **name:** application name
- **defaultAction:** Firewall permission. Set to `ALLOW` for the public to gain access [Default: DENY]
- **ip{Admin,White}listId:** ip lists on who can and cannot access the endpoint [Default: empty ipset]

See `variables.tf` for extended list of OWASP inputs that can be configured.

## Output
- **id:** aws_waf_web_acl id

## Rules

```bash
ACL
|- Blacklist Group
|  |- Bad Bot Rule
|  |- Blacklist Rule
|  |- HTTP Flood Rule           # ** Requires Manual Enabling **
|  |- Reputation List Rule
|  |- Scanner Probes Rule
|- OWASP Group
|  |- Admin Url Rule
|  |- Auth Token Rule
|  |- CSRF Rule
|  |- Paths Rule
|  |- Server Side Include Rule
|  |- Size Restriction Rule
|  |- SQL Injection Rule
|  |- XSS Rule
|- Whitelist Rule


```


## TODO
- [ ] Easier ip list management 
- [ ] Bug: terraform unable to att raterule to acl - add manually as workaround
- [ ] Add in to toggle for each rule (max 10)


## Sources
- [AWS WAF Sample](https://github.com/awslabs/aws-waf-sample)
- [AWS WAF Security Automations](https://aws.amazon.com/solutions/aws-waf-security-automations)
- [AWS WAF to Mitigate OWASP's Top 10 Web Application Vulnerabilities](https://aws.amazon.com/about-aws/whats-new/2017/07/use-aws-waf-to-mitigate-owasps-top-10-web-application-vulnerabilities/)
