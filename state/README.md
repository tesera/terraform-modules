# terraform-state-module
Terraform module: Set up state backend using S3 &amp; DynamoDB

## Use
`global/init/main.tf`:
```hcl-terraform
variable "name" {
  default = "NAME"
}
variable "region" {
  default = "us-east-1"
}
variable "profile" {
  default = "your-profile"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "state" {
  source = "git@github.com/tesera/state"
  name = "${var.name}"
}

# Used in backend.s3 block
output "backend_s3_region" {
  value = "${var.region}"
}
output "backend_s3_profile" {
  value = "${var.profile}"
}
output "backend_s3_dynamodb_table" {
  value = "${module.state.dynamodb_table_id}"
}
output "backend_s3_bucket" {
  value = "${module.state.s3_bucket_id}"
}
output "backend_s3_bucket_logs" {
  value = "${module.state.s3_bucket_logs_id}"
}

```

### Remote State
```hcl-terraform
terraform {
  backend "s3" {
    bucket         = "tfstate-NAME"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    profile        = "tesera"
    dynamodb_table = "tfstate-NAME"
    kms_key_id     = "arn:aws:kms:us-east-1:<account_id>:key/<key_id>"
  }
}
```

## Inputs
- **name:** Makes name unique tfstate-${name} [Optional]

Ensure `.gitignore` saves these files.
```
# Compiled files
*.tfstate
*.tfstate.backup
!global/init/terraform.tfstate
!global/init/terraform.tfstate.backup

# Module directory
.terraform/
```

