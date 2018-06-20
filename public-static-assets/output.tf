output "bucket_name" {
  value = "${aws_s3_bucket.main.id}"
}

output "cloudfront_distribution_id" {
  value = "${aws_cloudfront_distribution.main.id}"
}

output "cloudfront_distribution_domain_name" {
  value = "${aws_cloudfront_distribution.main.domain_name}"
}
