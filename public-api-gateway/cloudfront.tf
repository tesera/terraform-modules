data "aws_caller_identity" "current" {}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = true

  aliases = "${var.aliases}"

  origin {
    origin_id   = "${local.name}-apig"
    domain_name = "${replace(aws_api_gateway_deployment.main.invoke_url, "/^https:\\/\\/(.*?)\\/.*$/", "$1")}"
    origin_path = "/${aws_api_gateway_deployment.main.stage_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"

      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  default_cache_behavior {
    target_origin_id = "${local.name}-apig"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]

    cached_methods = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0                   # 1d
    max_ttl                = 0                   # 1y
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${local.logging_bucket}"
    prefix          = "AWSLogs/${data.aws_caller_identity.current.account_id}/CloudFront/${var.aliases[0]}/"
  }

  web_acl_id = "${var.web_acl_id}"

  tags = "${merge(local.tags, map(
    "Name", "${local.name} API Gateway"
  ))}"
}

// TODO update archive policy
resource "aws_s3_bucket" "main-logs" {
  bucket = "${local.name}-api-access-logs"
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}
