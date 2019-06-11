


```hcl-terraform
provider "aws" {
  profile = "app-${terraform.workspace}"
  region  = "us-east-1"
  alias   = "edge"
}

module "uptime" {
  
  providers = {
    aws = "aws.edge"
  }
}

```
