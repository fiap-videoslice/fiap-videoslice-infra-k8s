terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }
  }

  backend "s3" {

  }

  required_version = "~> 1.9.3"
}
