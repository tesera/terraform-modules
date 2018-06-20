data "aws_acm_certificate" "main" {
  provider = "aws.edge"
  domain = "${var.env != "prod" ? "${var.env}-": ""}api.registration.redcross.ca"
  statuses = [
    "ISSUED"]
}


module "waf" {
  source = "../waf-owasp-rules"
  name = "${var.env}EmisRegistrationApi"
  defaultAction = "${var.defaultAction}"

  ipAdminListId = "${var.ipAdminListId}"
  ipBlackListId = "${var.ipBlackListId}"
  ipWhiteListId = "${var.ipWhiteListId}"
}

// comment out for dev
resource "aws_s3_bucket" "api_access_logs" {
  bucket = "${var.env}-emis-registration-api-access-logs"
  acl = "private"
}

resource "aws_cloudfront_distribution" "api_distribution" {
  depends_on = ["aws_s3_bucket.api_access_logs"]
  origin {
    domain_name = "${var.domain_name}"
    origin_id = "${var.domain_name}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1.2"]
    }
  }

  enabled = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket = "${aws_s3_bucket.api_access_logs.bucket_domain_name}" //"${var.env}-emis-registration-api-access-logs.s3.amazonaws.com"
    // allow for manual deploy of s3 bucket - dev aws bug // "${aws_s3_bucket.api_access_logs.bucket_domain_name}"
  }

  aliases = [
    "${var.env != "prod" ? "${var.env}-": ""}api.registration.redcross.ca",
    "${var.env != "prod" ? "${var.env}-": ""}api.inscription.croixrouge.ca"]

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"]
    cached_methods = ["HEAD","GET","OPTIONS"]
    target_origin_id = "${var.domain_name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 1
    max_ttl = 5
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.main.arn}"
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method = "sni-only"
  }

  web_acl_id = "${module.waf.id}"
}
