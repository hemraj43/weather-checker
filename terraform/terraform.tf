terraform {
  required_version = ">= 1.8.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.50.0"
    }
  }

  # S3 backend can be used to store terraform state
  # backend "s3" {
  #   bucket         = "S3-bucket-name"
  #   dynamodb_table = "terraform"
  #   key            = "weather-checker"
  # }
}

provider "aws" {
  default_tags {
    tags = {
      Terraform   = "true"
      Application = var.application
      Name        = var.instance_name
    }
  }
}
