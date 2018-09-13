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

### routes.json

- **method:** HTTP Method (`GET`,`POST`,`PUT`, `PATCH`,`DELETE`)
- **path:** uri path, must start with `/`, supports inline var using `:id` and `{id}`
- **src:** path, relative to `lambda_dir` from module input

```json
[
  {
    "method": "GET",
    "path": "/ping/pong",
    "src": "ping"
  },
  {
    "method": "GET",
    "path": "/ping/:pong",
    "src": "ping"
  },
  {
    "method": "GET",
    "path": "/ping/pang",
    "src": "ping"
  }
]
```

## Input
- **name:** Application name
- **aliases:** Cloudfront Aliases
- **waf_acl_id:** WAF ACL ID [Optional]

- **authorizer_dir:** Path to authorizer lambda (nodejs) folder. ex `${path.module}/authorizer` and container `package.json` and `index.js`
- **lambda_dir:** Set reference directory for lambda functions. ex `${path.module}/routes`
- **lambda_config_path:** Path to lambda routing config file. ex `${path.module}/routes.json`

- **handler:** Set default lambda `handler`, applies to authorizer. [Default: `index.handler`]
- **runtime:** Set default lambda `runtume`, applies to authorizer. [Default: `nodejs8.10`]
- **memory_size:** Set default lambda `memory_size`, applies to authorizer. [Default: `128`]
- **timeout:** Set default lambda `timeout`, applies to authorizer. [Default: `30`]

## Output
- **id:** `${aws_cloudfront_distribution.main.id}` CloudFront Distribution Id for CI/CD to trigger cache clearing (`aws cloudfront create-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --paths /index.html`)
- **domain_name:** `${aws_cloudfront_distribution.main.domain_name}` CloudFront Domain Name for DNS updating.
- **hosted_zone_id:** `${aws_cloudfront_distribution.main.hosted_zone_id}` CloudFront Hosted Zone ID.
- **rest_api_id:** APIG ID
- **root_resource_id:** APIG `root_resource_id`
- **authorizer_id:** id of authorizer lambda

## TODO
- [ ] connect `handler` and `runtime` to endpoints
