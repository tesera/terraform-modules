data "aws_caller_identity" "current" {
}

resource "aws_macie_member_account_association" "example" {
  member_account_id = data.aws_caller_identity.current.account_id
}

# https://docs.aws.amazon.com/macie/latest/userguide/macie-setting-up.html#macie-setting-up-enable

resource "aws_macie_s3_bucket_association" "example" {
  bucket_name = "tf-macie-example"
  prefix      = "data"

  classification_type {
    one_time = "FULL"
  }
}

