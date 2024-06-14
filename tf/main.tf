terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.54"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}