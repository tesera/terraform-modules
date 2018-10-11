variable "name" {
  type = "string"
}

variable "profile" {
  type = "string"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.profile}"
}

module "state" {
  source = "git@github.com:willfarrell/terraform-state-module"
  name   = "${var.name}"
}

output "backend_s3_dynamodb_table" {
  value = "${module.state.dynamodb_table_id}"
}
output "backend_s3_region" {
  value = "us-east-1"
}
output "backend_s3_bucket" {
  value = "${module.state.s3_bucket_id}"
}
output "backend_s3_bucket_logs" {
  value = "${module.state.s3_bucket_logs_id}"
}

