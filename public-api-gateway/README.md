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

### Place inside VPC
See [AWS Docs](https://docs.aws.amazon.com/lambda/latest/dg/vpc.html) for limitations.
```hcl-terraform
resource "aws_security_group" "lambda" {
  name   = "${var.name}-api"
  vpc_id = "${var.vpc_id}"

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}
```
