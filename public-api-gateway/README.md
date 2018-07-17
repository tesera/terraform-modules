# terraform-api-endpoint-module
Terraform Module: CloudFront, ACM, ApiGateway


### module
```hcl-terraform
module "api" {
  source                  = "../../public-api-gateway"
  name                    = "${local.name}"

  aliases                 = ["${local.domain}"]
  acm_certificate_arn     = "${data.aws_acm_certificate.main.arn}"
  web_acl_id              = "${module.waf.id}"
  authorizer_path         = "${path.module}/authorizer"
}
```
