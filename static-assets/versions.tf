
terraform {
  required_version = ">= 0.13"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.edge]
    }
  }
}
