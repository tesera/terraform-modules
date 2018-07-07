output "bucket" {
  value = "${aws_s3_bucket.main.id}"
}

output "server_side_encryption" {
  value = "aws:kms"
}

output "cloudfront_distribution_id" {
  value = "${aws_cloudfront_distribution.main.id}"
}

output "cloudfront_distribution_domain_name" {
  value = "${aws_cloudfront_distribution.main.domain_name}"
}
