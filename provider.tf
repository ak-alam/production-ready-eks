terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.32.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
   default_tags {
   tags = {
     Owner       = "Akbar"
     Project     = "Learn-and"
     Environment = "${terraform.workspace}"
     ManagedBy   = "Terraform"

   }
 }
}