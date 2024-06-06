## production-ready-eks

#### Resources Created by the module.
* VPC
* Security Group
* EKS Cluster
* Addons
* HPA/VPA
* Ingress controller
* Karpenter (Node ASG)
* Prometheus grafana (Kube-Prometheus-Stack)
* 
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