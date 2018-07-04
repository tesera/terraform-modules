resource "aws_cloudfront_distribution" "main" {
  depends_on = ["aws_lambda_function.response_headers"]

  enabled      = true
  http_version = "http2"

  #is_ipv6_enabled = true

  aliases = "${var.aliases}"
  origin {
    origin_id   = "${var.name}"
    domain_name = "${aws_s3_bucket.main.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    }
  }
  default_cache_behavior {
    target_origin_id = "${var.name}"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400    # 1d
    max_ttl                = 31536000 # 1y
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = "${aws_lambda_function.response_headers.qualified_arn}"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.s3_static_website_logs.bucket_domain_name}"
  }
  default_root_object = "index.html"
  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 5
    response_page_path    = "/index.html"
    response_code         = 200
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  web_acl_id = "${var.web_acl_id}"
}

resource "aws_s3_bucket" "s3_static_website_logs" {
  bucket = "${var.name}-access-logs"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}
