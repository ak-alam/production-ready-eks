# terraform {
# #   required_version = ">= 1.5.4" #terraform version
#   #provider name and version
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "5.15.0"
#     }
#   }
# }

# #provider configuration
# provider "aws" {
#   # Configuration options
#   region  = "us-east-1"
#   profile = "default"
# }


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
}