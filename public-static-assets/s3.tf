# TODO add in logging bucket??

resource "aws_s3_bucket" "main-logs" {
  bucket              = "${local.name}-static-assets-logs"
  acl                 = "log-delivery-write"
  acceleration_status = "Enabled"

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix  = "log/"
    tags {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  tags {
    Name = "${local.name} Terraform State Logging"
    Terraform = "true"
  }
}

resource "aws_s3_bucket" "main" {
  bucket              = "${local.name}-static-assets"
  region              = "${local.aws_region}"
  acl                 = "private"
  acceleration_status = "Enabled"

  versioning {
    enabled = false
  }

  logging {
    target_bucket = "${aws_s3_bucket.main-logs.id}"
    target_prefix = "log/"
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
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "${local.sse_algorithm}"
      }
    }
  }

  tags {
    Name      = "${local.name} Static Assets"
    Terraform = "true"
  }
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
