


provider "aws" {
  region  = "us-east-2"
  profile = "tesera"
}

provider "aws" {
  region  = "us-east-1"
  profile = "tesera"
  alias   = "edge"
}

//module "cluster" {
//  source         = "../modules/cluster"
//}

module "vpc" {
  source  = "../vpc"
  name    = "test"
}
