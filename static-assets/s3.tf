resource "aws_s3_bucket" "main_s3_logs" {
  count               = var.logging_bucket == "" ? 1 : 0
  bucket              = "${local.name}-static-assets-access-logs"
  acl                 = "log-delivery-write"
  acceleration_status = "Enabled"

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = merge(
      local.tags,
      {
        rule      = "log"
        autoclean = "true"
      }
    )

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

  tags = merge(
    local.tags,
    {
      Name     = "${local.name} Static Assets Logs"
      Security = "SSE:AWS"
    }
  )
}

resource "aws_s3_bucket" "main" {
  bucket              = "${local.name}-static-assets"
  acl                 = "private"
  acceleration_status = "Enabled"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = var.cors_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  versioning {
    enabled = false
  }

  logging {
    target_bucket = local.logging_bucket
    target_prefix = "AWSLogs/${local.account_id}/S3/${local.name}-static-assets/"
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
      Name     = "${local.name} Static Assets"
      Security = "SSE:AWS"
    }
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

  dynamic "statement" {
    for_each = var.access_accounts

    content {
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:GetObjectTagging"
      ]

      resources = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*",
      ]

      principals {
        type = "AWS"

        identifiers = [
          "arn:aws:iam::${statement.value}:root"
        ]
      }

      sid = "Allow access from HRIS ${statement.key}"
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

