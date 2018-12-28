# Regional Web Application Firewall (WAF)
To be used with Application Load Balancers.

Ported from [AWS WAF to Mitigate OWASP's Top 10 Web Application Vulnerabilities](https://aws.amazon.com/about-aws/whats-new/2017/07/use-aws-waf-to-mitigate-owasps-top-10-web-application-vulnerabilities/) Template (2017-10-01).


## Setup

### Module
```hcl-terraform
module "waf" {
  source        = "git@github.com:tesera/terraform-modules//waf-region-owasp"
  name          = "${var.env}ApplicationName"
  defaultAction = "${var.defaultAction}"

  ipAdminListId = "${aws_waf_ipset.admin.id}"
  ipBlackListId = "${aws_waf_ipset.black.id"
  ipWhiteListId = "${aws_waf_ipset.white.id}"
}
```

### IP Lists
```hcl-terraform
resource "aws_waf_ipset" "white" {
  name = "${var.name}-white-ipset"
}
```

## Input
- **name:** application name
- **defaultAction:** Firewall permission. Set to `ALLOW` for the public to gain access [Default: DENY]
- **ip{Admin,White,Black}ListId:** ip lists on who can and cannot access the endpoint [Default: empty ipset]

See `variables.tf` for extended list of OWASP inputs that can be configured.

## Output
- **id:** aws_waf_web_acl id

## TODO
- [ ] Easier ip list management (See CRC module)
