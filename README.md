## production-ready-eks

#### Resources Created by the module.
* VPC
* EKS Cluster

#### How To Run The Project

```bash

#Initialize project
terraform init

#Validate 
terraform validate

#Plan 
terraform plan -var-file configs/dev.tfvars

#Apply
terraform apply -var-file configs/dev.tfvars

```