provider "aws" {
  region  = var.region
  profile = "lacework-devtest"
  version = "~> 2.28"
}

