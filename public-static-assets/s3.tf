# TODO add in logging bucket??

resource "aws_s3_bucket" "main" {
  bucket              = "${local.name}-static-assets"
  region              = "${local.aws_region}"
  acl                 = "private"
  acceleration_status = "Enabled"

  versioning {
    enabled = false
  }

// CloudFront unable to reach `aws:kms` - not supported yet (2018-07-10)
//  server_side_encryption_configuration {
//    rule {
//      apply_server_side_encryption_by_default {
//        sse_algorithm = "aws:kms"
//      }
//    }
//  }

// CloudFront forces a d download when AES256 is used
  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        sse_algorithm = "${local.sse_algorithm}"
      }
    }
  }

  tags {
    Name      = "${local.name} Static Assets"
    Terraform = "true"
  }
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 static assets origin access policy"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions    = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources  = [
      "${aws_s3_bucket.main.arn}",
      "${aws_s3_bucket.main.arn}/*",
    ]

    principals = {
      type        = "AWS"
      identifiers = [
        "${aws_cloudfront_origin_access_identity.main.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = "${aws_s3_bucket.main.id}"
  policy = "${data.aws_iam_policy_document.s3.json}"
}
