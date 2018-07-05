# Web Application Firewall (WAF)


Ported from [AWS WAF to Mitigate OWASP's Top 10 Web Application Vulnerabilities](https://aws.amazon.com/about-aws/whats-new/2017/07/use-aws-waf-to-mitigate-owasps-top-10-web-application-vulnerabilities/) Template (2017-10-01).


## Setup

### Module
```hcl-terraform
module "waf" {
  source        = "github.com/tesera/terraform-modules/waf-owasp"
  name          = "${var.env}ApplicationName"
  defaultAction = "${var.defaultAction}"

  ipAdminListId = "${var.ipAdminListId}"
  ipBlackListId = "${var.ipBlackListId}"
  ipWhiteListId = "${var.ipWhiteListId}"
}
```

### IP Lists
```hcl-terraform
# place holder for admin, white, black ip lists
resorce "aws_waf_ipset" "empty" {
  name = "${var.name}-empty-ipset"
}
```

## Input
- **name:** application name
- **defaultAction:** Firewall permission. Set to `ALLOW` for the public to gain access [Default: DENY]
- **ip{Admin,White,Black}ListId:** ip lists on who can and cannot access the endpoint

See `variables.tf` for extended list of OWASP inputs that can be configured.

## Output
- **id:** aws_waf_web_acl id

## TODO
- [ ] Easier ip list management (See CRC module)
