# Web Application Firewall (WAF)


Ported from [AWS WAF to Mitigate OWASP's Top 10 Web Application Vulnerabilities](https://aws.amazon.com/about-aws/whats-new/2017/07/use-aws-waf-to-mitigate-owasps-top-10-web-application-vulnerabilities/) Template (2017-10-01).


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


## TODO
- [ ] Easier ip list management (See CRC module)
