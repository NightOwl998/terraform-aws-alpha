terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket         = "terraform-remote-state-d67cd9c15c2"
    key            = "level2.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-remote-state"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}



