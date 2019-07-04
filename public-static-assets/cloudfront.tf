data "aws_caller_identity" "current" {}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 static assets origin access policy"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"
  web_acl_id      = "${var.web_acl_id}"

  aliases = "${var.aliases}"

  viewer_certificate {
    cloudfront_default_certificate = "${(var.acm_certificate_arn == "")}"
    acm_certificate_arn            = "${var.acm_certificate_arn}"
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  origin {
    origin_id   = "${local.name}"
    domain_name = "${aws_s3_bucket.main.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    target_origin_id = "${local.name}"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400

    # 1d
    max_ttl = 31536000

    # 1y
    compress = true

    forwarded_values {
      query_string = false

      # TODO add in headers here

      cookies {
        forward = "none"
      }
    }

    # TODO update when v0.12 released
    #lambda_function_association {
    #  event_type = "viewer-request"
    #  lambda_arn = "${local.lambda_viewer_request_enabled ? aws_lambda_function.viewer_request.qualified_arn : ""}"
    #}

    #lambda_function_association {
    #  event_type = "origin-request"
    #  lambda_arn = "${local.lambda_origin_request_enabled ? aws_lambda_function.origin_request.qualified_arn : ""}"
    #}

    #lambda_function_association {
    #  event_type = "viewer-response"
    #  lambda_arn = "${local.lambda_viewer_response_enabled ? aws_lambda_function.viewer_response.qualified_arn : ""}"
    #}

    // TODO - https://stackoverflow.com/questions/46262030/single-page-application-with-lambdaedge
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = "${local.lambda_origin_response_enabled ? aws_lambda_function.origin_response.qualified_arn : ""}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_root_object = "index.html"

  /*custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/index.html"
  }*/

  logging_config {
    include_cookies = false
    bucket          = "${local.logging_bucket}.s3.amazonaws.com"
    prefix          = "AWSLogs/${data.aws_caller_identity.current.account_id}/CloudFront/${var.aliases[0]}/"
  }

  tags = "${merge(local.tags, map(
    "Name", "${local.name} CloudFront"
  ))}"
}
