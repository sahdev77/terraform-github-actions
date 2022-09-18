terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.12.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1" # define region as per your account
}

resource "aws_s3_bucket" "new_bucket" {
  bucket = "demo-github-action-tf-medium"

  object_lock_enabled = false

  tags = {
    Environment = "Prod"
  }
}
