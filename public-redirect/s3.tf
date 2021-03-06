resource "aws_s3_bucket" "main" {
  bucket = "${local.name}-redirect"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://${var.redirect}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = local.sse_algorithm
      }
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name} Domain Redirection"
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

