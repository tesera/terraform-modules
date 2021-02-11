module "defaults" {
  source = "../defaults"
  name   = var.name
  tags   = var.default_tags
}

locals {
  region     = module.defaults.region
  tags       = module.defaults.tags
  name       = module.defaults.name
  account_id = module.defaults.account_id

  //sse_algorithm = "AES256"

  logging_bucket = var.logging_bucket != "" ? var.logging_bucket : aws_s3_bucket.main_s3_logs[0].id
}

