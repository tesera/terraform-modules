resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 domain redirect origin access policy"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = true

  aliases = "${var.aliases}"

  origin {
    origin_id   = "${local.name}-redirect"
    domain_name = "${aws_s3_bucket.main.website_endpoint}"

    # Workaround: https://github.com/terraform-providers/terraform-provider-aws/issues/4757
    #s3_origin_config {
    #  origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    #}

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "${local.name}-redirect"
    allowed_methods  = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

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
    prefix          = "CloudFront/${var.aliases[0]}/"
  }

  tags = "${merge(local.tags, map(
    "Name", "${local.name} Domain Redirection"
  ))}"
}

resource "aws_s3_bucket" "main-logs" {
  bucket = "${local.name}-cdn-redirect-access-logs"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}
