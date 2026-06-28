terraform {

  required_version = ">= 1.5"

  backend "s3" {
    bucket = "arshenoor-capstone-tfstate"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}