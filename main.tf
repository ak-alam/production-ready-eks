module "vpc" {
  source               = "./modules/vpc" #referencing the source module
  identifier           = var.identifier
  vpc_cidr             = var.cluster_vpc.vpc_cidr
  public_subnets       = var.cluster_vpc.public_subnets
  private_subnets      = var.cluster_vpc.private_subnets
}