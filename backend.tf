# terraform {
#   backend "s3" {
#     bucket               = "bucket-name"      
#     key                  = "terraform.tfstate"         
#     region               = "us-east-1"                 
#     workspace_key_prefix = "workspace-prefix"                
#     dynamodb_table       = "dynamodb_table" 
#     encrypt              = true
#   }
# }