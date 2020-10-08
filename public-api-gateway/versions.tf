
terraform {
  required_version = ">= 0.13"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
    external = {
      source = "hashicorp/external"
    }
  }
}
