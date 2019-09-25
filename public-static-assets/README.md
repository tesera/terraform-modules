# Terraform App Endpoint
Creates CloudFront (w/ WAF and Lambda) and S3 Bucket.

## Setup
### Requirements

- Edge provider in the root.

```hcl-terraform
provider "aws" {
    profile = "${local.workspace["profile"]}-${local.workspace["env"]}"
    region  = "us-east-1"
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
  source = "../waf"
  name   = "${local.workspace["name"]}"
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
  source              = "./modules/public-static-assets"

  name                = "${var.env}-myapp"
  aliases             = ["${var.env != "prod" ? "${var.env}-": ""}appname.example.com"]
  acm_certificate_arn = data.aws_acm_certificate.main.arn
  web_acl_id          = module.waf.id
  lambda = {
    "origin-request" = file("${path.module}/origin-request.js")
    "viewer-request" = file("${path.module}/viewer-request.js")
    "viewer-response" = file("${path.module}/viewer-response.js")
    "origin-response" = file("${path.module}/origin-response.js")
  }
  error_codes      = { 
    404 = "/404.html"
  }
  logging_bucket         = "${local[terraform.workspace].name}-${terraform.workspace}-edge-logs"
  
  providers = {
    aws = "aws"
    aws.edge = "aws.edge"
  }
}
```

## Input
- **name:** AWS S3 Bucket name. `${var.env}-${var.name}`.
- **aliases:** CloudFront Aliases.
- **acm_certificate_arn:** Domain Certificate ARN
- **web_acl_id:** WAF ACL ID
- **lambda:** lambda@Edge functions
- **cors_origins:** URL to apply to CORS. [Default: `["*"]`]
- **error_codes:** map of paths for error codes. Defaults: none
- **logging_bucket:** Bucket id for where teh logs should be sent

## Output
- **bucket:** `${aws_s3_bucket.main.id}` Full name of the S3 bucket.
- **id:** `${aws_cloudfront_distribution.main.id}` CloudFront Distribution Id for CI/CD to trigger cache clearing (`aws cloudfront create-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --paths /index.html`)
- **domain_name:** `${aws_cloudfront_distribution.main.domain_name}` CloudFront Domain Name for DNS updating.
- **hosted_zone_id:** `${aws_cloudfront_distribution.main.hosted_zone_id}` CloudFront Hosted Zone ID.

## TODO
- add in price class var
