resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 static assets origin access policy"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true

  aliases             = "${var.aliases}"

  origin {
    origin_id   = "${local.name}"
    domain_name = "${aws_s3_bucket.main.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    target_origin_id       = "${local.name}"
    allowed_methods        = [
      "GET",
      "HEAD",
      "OPTIONS"]
    cached_methods         = [
      "GET",
      "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    # 1d
    max_ttl                = 31536000
    # 1y
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.main-cdn-logs.bucket_domain_name}"
  }

  default_root_object = "index.html"

  // TODO - https://stackoverflow.com/questions/46262030/single-page-application-with-lambdaedge
  // 404 pages don't run through lambda@edge response
  // https://aws.amazon.com/about-aws/whats-new/2017/12/lambda-at-edge-now-allows-you-to-customize-error-responses-from-your-origin/
  //  custom_error_response {
  //    error_code            = 404
  //    error_caching_min_ttl = 5
  //    response_page_path    = "/index.html"
  //    response_code         = 200
  //  }

  web_acl_id          = "${var.web_acl_id}"

  tags                = "${merge(local.tags, map(
    "Name", "${local.name} CloudFront"
  ))}"
}

resource "aws_s3_bucket" "main-cdn-logs" {
  provider = "aws.edge"
  bucket   = "${local.name}-${terraform.workspace}-cdn-access-logs"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }

  tags     = "${merge(local.tags, map(
    "Name", "${local.name} CloudFront Access Logs"
  ))}"
}
