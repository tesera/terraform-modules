# SSE:AWS not supportted
resource "aws_s3_bucket" "main-s3-logs" {
  bucket              = "${local.name}-${terraform.workspace}-static-assets-access-logs"
  acl                 = "log-delivery-write"
  acceleration_status = "Enabled"

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

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

  tags = "${merge(local.tags, map(
    "Name", "${local.name} Static Assets Access Logs"
  ))}"
}

resource "aws_s3_bucket" "main" {
  bucket              = "${local.name}-${terraform.workspace}-static-assets"
  acl                 = "private"
  acceleration_status = "Enabled"

  versioning {
    enabled = false
  }

  logging {
    target_bucket = "${local.logging_bucket}"
    target_prefix = "S3/${local.name}-${terraform.workspace}-static-assets/"
  }

  // CloudFront unable to reach `aws:kms` - not supported yet (2018-07-10)
  //  server_side_encryption_configuration {
  //    rule {
  //      apply_server_side_encryption_by_default {
  //        sse_algorithm = "aws:kms"
  //      }
  //    }
  //  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "${local.sse_algorithm}"
      }
    }
  }
  tags = "${merge(local.tags, map(
    "Name", "${local.name} Static Assets"
  ))}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.main.arn}",
      "${aws_s3_bucket.main.arn}/*",
    ]

    principals = {
      type = "AWS"

      identifiers = [
        "${aws_cloudfront_origin_access_identity.main.iam_arn}",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket   = "${aws_s3_bucket.main.id}"
  policy   = "${data.aws_iam_policy_document.s3.json}"
}
