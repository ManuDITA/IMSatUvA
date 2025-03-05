terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }
  }

  # Store the state file in an S3 bucket to keep track of the state of the infrastructure between GitHub Actions
  # Source: https://medium.com/all-things-devops/how-to-store-terraform-state-on-s3-be9cd0070590
  backend "s3" {
    bucket         = "oicd-tfstates-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-lock-dynamodb"
  }
}

provider "aws" {
  region = var.aws_region
}