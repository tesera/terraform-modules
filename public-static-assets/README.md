# Terraform App Endpoint
Creates CloudFront (w/ WAF and Lambda) and S3 Bucket.

## Setup
### Requirements

- Edge provider in the root.

```hcl-terraform
provider "aws" {
    region  = "us-east-1"
    profile = "myapp"
    alias   = "edge"
}

```

-  ACM Certificate

```hcl-terraform
data "aws_acm_certificate" "main" {
  provider = "aws.edge"
  domain   = "${var.env}-appname.example.com"
  statuses = ["ISSUED"]
}
```

- Web Application Firewall (Optional)

```hcl-terraform
module "waf" {
  source = "git@github.com:tesera/terraform-modules//waf-owasp"
  name   = "${var.env}ApplicationName"
  defaultAction = "ALLOW"
  providers = {
    aws = "aws.edge"
  }
}
```

### Module
```hcl-terraform

module "logs" {
  source = "git@github.com:willfarrell/terraform-s3-logs-module?ref=v0.3.0"
  name   = "${local.workspace["name"]}-${terraform.workspace}-edge"
  tags   = {
    "Name": "Edge Logs"
  }
}

module "app" {
  source              = "git@github.com:tesera/terraform-modules//public-static-assets?ref=v0.4.0"

  name                = "${var.env}-myapp"
  aliases             = ["${var.env != "prod" ? "${var.env}-": ""}appname.example.com"]
  acm_certificate_arn = "${data.aws_acm_certificate.main.arn}"
  web_acl_id          = "${module.waf.id}"
  lambda_origin_response = "${file("${path.module}/viewer-response.js")}"
  logging_bucket         = "${local[terraform.workspace].name}-${terraform.workspace}-edge-logs"
  
  providers = {
    aws = "aws.edge"
  }
}
```

## Input
- **name:** AWS S3 Bucket name. `${var.env}-${var.name}`.
- **aliases:** CloudFront Aliases.
- **acm_certificate_arn:** Domain Certificate ARN
- **web_acl_id:** WAF ACL ID
- **lambda_viewer_request:** By default this module includes a lambda function to add security headers to all responses. This can be overwritten using the above example.
- **lambda_origin_request:** By default this module passes the request through.
- **lambda_viewer_response:** By default this module includes a lambda function to add index.html as the default sub directory object. This can be overwritten using the above example.
- **lambda_origin_response:** By default this module passes the response through.
- **lambda_\*_default:** Boolean to determine if the default lambda should be attached to the CloudFront [Default: false]
- **logging_bucket:** Bucket id for where teh logs should be sent

## Output
- **bucket:** `${aws_s3_bucket.main.id}` Full name of the S3 bucket.
- **id:** `${aws_cloudfront_distribution.main.id}` CloudFront Distribution Id for CI/CD to trigger cache clearing (`aws cloudfront create-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --paths /index.html`)
- **domain_name:** `${aws_cloudfront_distribution.main.domain_name}` CloudFront Domain Name for DNS updating.
- **hosted_zone_id:** `${aws_cloudfront_distribution.main.hosted_zone_id}` CloudFront Hosted Zone ID.

## TODO
- add in price class var
