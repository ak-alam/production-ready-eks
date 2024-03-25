module "vpc" {
  source               = "./modules/vpc" #referencing the source module
  identifier           = var.identifier
  vpc_cidr             = var.cluster_vpc.vpc_cidr
  public_subnets       = var.cluster_vpc.public_subnets
  private_subnets      = var.cluster_vpc.private_subnets
}

module "eks" {
  source = "./modules/eks"
  identifier           = var.identifier
  cluster_version = var.eks_settings.cluster_version
  #security_group_ids = module.cluster_sg.output.sg #need to update 
  subnet_ids = module.vpc.outputs.private_subnets #cluster subnets

  ng_subnet_ids = module.vpc.outputs.private_subnets #node group subnets
  ng_desire_size = var.eks_settings.ng_desire_size
  ng_max_size = var.eks_settings.ng_max_size
  ng_min_size = var.eks_settings.ng_min_size
  ng_capacity_type = var.eks_settings.ng_capacity_type
  ng_instance_types = var.eks_settings.ng_instance_types
  
  depends_on = [ module.vpc ]
}