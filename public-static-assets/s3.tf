resource "aws_s3_bucket" "main" {
  bucket              = "${local.name}-${terraform.workspace}-static-assets"
  acl                 = "private"
  acceleration_status = "Enabled"

  versioning {
    enabled = false
  }

  logging {
    target_bucket = local.logging_bucket
    target_prefix = "AWSLogs/${local.account_id}/S3/${local.name}-${terraform.workspace}-static-assets/"
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
        sse_algorithm = "AES256"
      }
    }
  }
  tags = merge(
    local.tags,
    {
      "Name"     = "${local.name} Static Assets"
      "Security" = "SSE:AWS"
    },
  )
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.main.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

