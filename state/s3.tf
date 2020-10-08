resource "aws_s3_bucket" "main" {
  bucket = "terraform-state${local.name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  #logging {
  #  target_bucket = "${module.logs.id}"
  #  target_prefix = "log/"
  #}

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = local.sse_algorithm
      }
    }
  }

  tags = {
    Name      = "Terraform Remote State"
    Terraform = true
    //Security = "SSE:KMS"
    Security = "SSE:AWS"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Causes: Failed to save state: failed to upload state: AccessDenied: Access Denied
//	status code: 403, request id: ***********, host id: *********
//resource "aws_s3_bucket_policy" "main" {
//  bucket = "${aws_s3_bucket.main.id}"
//  policy =<<POLICY
//{
//  "Version": "2012-10-17",
//  "Id": "Terraform Remote State Policy",
//  "Statement": [
//     {
//        "Sid":"DenyIncorrectEncryptionHeader",
//        "Effect":"Deny",
//        "Principal":"*",
//        "Action":"s3:PutObject",
//        "Resource":"arn:aws:s3:::${aws_s3_bucket.main.id}/*",
//        "Condition":{
//           "StringNotEquals":{
//             "s3:x-amz-server-side-encryption": "${local.sse_algorithm}"
//           }
//        }
//     },
//     {
//        "Sid":"DenyUnEncryptedObjectUploads",
//        "Effect":"Deny",
//        "Principal":"*",
//        "Action":"s3:PutObject",
//        "Resource":"arn:aws:s3:::${aws_s3_bucket.main.id}/*",
//        "Condition":{
//           "Null":{
//              "s3:x-amz-server-side-encryption":"true"
//           }
//        }
//     }
//  ]
//}
//POLICY
//}
