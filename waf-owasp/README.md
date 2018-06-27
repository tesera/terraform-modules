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
- [aws_waf_ipset]()
```hcl-terraform
# place holder for admin, white, black ip lists
resorce "aws_waf_ipset" "empty" {
  name = "${var.name}-empty-ipset"
}

## TODO
- [ ] Easier ip list management (See CRC module)
