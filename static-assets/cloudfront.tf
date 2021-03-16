resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 static assets origin access policy"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"
  web_acl_id      = var.web_acl_id

  aliases = var.aliases

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn
    minimum_protocol_version       = var.acm_certificate_arn == "" ? "TLSv1" : "TLSv1.2_2018"
    ssl_support_method             = var.acm_certificate_arn == "" ? "" : "sni-only"
  }

  origin {
    origin_id   = local.name
    domain_name = aws_s3_bucket.main.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = local.name

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = var.cached_methods

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400

    # 1d
    max_ttl = 31536000

    # 1y
    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = var.whitelisted_headers
    }

    dynamic "lambda_function_association" {
      for_each = keys(var.lambda)
      content {
        event_type = lambda_function_association.value
        lambda_arn = aws_lambda_function.lambda[lambda_function_association.key].qualified_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_root_object = "index.html"

  dynamic "custom_error_response" {
    for_each = var.error_codes == "" ? {} : var.error_codes
    content {
      error_code         = custom_error_response.key
      response_code      = 200
      response_page_path = custom_error_response.value
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${local.logging_bucket}.s3.amazonaws.com"
    prefix          = "AWSLogs/${local.account_id}/CloudFront/${local.name}/"
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name} CloudFront"
    }
  )
}

