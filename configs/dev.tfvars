identifier           = "cloudops"
cluster_vpc = {
    vpc_cidr             = "10.0.0.0/16"
    public_subnets       = ["10.0.1.0/24", "10.0.3.0/24"]
    private_subnets      = ["10.0.2.0/24", "10.0.4.0/24"]
}

eks_settings = {
    cluster_version = 1.28
    ng_max_size = 3
    ng_desire_size = 1
    ng_min_size = 1
    ng_capacity_type = "ON_DEMAND"
    ng_instance_types = ["t2.micro"]


}