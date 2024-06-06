
variable "identifier" {
  type = string
    description = "The projector identifier"
}

variable "cluster_version" {
  description = "Desired version of kubernetes, if not specify this value will be latest"
  default = "1.28"
}

variable "endpoint_private_access" {
  description = "EKS private API server endpoint is enabled"
  type = bool
  default = false
}

variable "endpoint_public_access" {
  description = "EKS public API server endpoint is enabled"
  type = bool
  default = true
}
variable "public_access_cidrs" {
  description = "List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled"
  type = list
  default = ["0.0.0.0/0"]
}
variable "security_group_ids" {
  description = "EKS cluster security group"
  type = list
  default = []
}

variable "subnet_ids" {
  description = "Subnets Used for EKS Cluster"
  type = list
  default = []
}


variable "ng_subnet_ids" {
  description = "Subnets Used for EKS NodeGroup"
  type = list
  default = []
}

variable "ng_desire_size" {
  description = "NodeGroup desired size"
  type = number
  default = 0
}

variable "ng_max_size" {
  description = "NodeGroup maximum size"
  type = number
  default = 0
}
variable "ng_min_size" {
  description = "NodeGroup minimum size"
  type = number
  default = 0
}

variable "ng_capacity_type" {
  description = "NodeGroup capacity type, valid values are [ON_DEMAND, SPOT]"
  type = string
  default = "SPOT"
}

variable "ng_disk_size" {
  description = "Node group disk size"
  type = number
  default = 20
}

variable "ng_ami_type" {
  description = "AMI for node group"
  type = string
  default = "AL2_x86_64"
}

variable "ng_instance_types" {
  description = "Instance type for node group"
  type = list
  default = ["t2.micro"]
}

variable "ng_max_unavailable_percentage" {
  description = "maximum percentage of nodes unavailable during a version update"
  type = number
  default = 50
}



variable "tags" {
  type = map
  default = {}
  description = "Tags to applied to the resources"
}