identifier           = "cloudops"
cluster_vpc = {
    vpc_cidr             = "10.0.0.0/16"
    public_subnets       = ["10.0.1.0/24", "10.0.3.0/24"]
    private_subnets      = ["10.0.2.0/24", "10.0.4.0/24"]
}

eks_additional_sg = {
    ingress_rule_list = [
        {
            source_security_group_id = null
            cidr_blocks              = ["0.0.0.0/0"],
            description              = "Default egress rule",
            from_port                = 0,
            protocol                 = "-1",
            to_port                  = 0
        }
    ]
    egress_rule_list = [
        {
            source_security_group_id = null
            cidr_blocks              = ["0.0.0.0/0"],
            description              = "Default egress rule",
            from_port                = 0,
            protocol                 = "all",
            to_port                  = 65535

        }
    ]
}

eks_settings = {
    cluster_version = 1.28
    ng_max_size = 3
    ng_desire_size = 3
    ng_min_size = 1
    ng_capacity_type = "ON_DEMAND"
    ng_instance_types = ["t3.medium"]
}