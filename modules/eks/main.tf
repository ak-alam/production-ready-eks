locals {
    default_tags = {
        Environment = "${terraform.workspace}"
        ManagedBy   = "Terraform"
    }
    #Defaults tags with the custom tags passed by users
    tags = "${merge(local.default_tags, var.tags)}"
}


# Cluster Roles, Policies and Policy attachment

data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster_role" {
  name               = "${var.identifier}-${terraform.workspace}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html

resource "aws_iam_role_policy_attachment" "aws_eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_cloudwatch_log_group" "control_plan_log_group" {
  name              = "/aws/eks/${var.identifier}-${terraform.workspace}/cluster"
  retention_in_days = 7
}


# EKS Cluster 
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.identifier}-${terraform.workspace}"
  version = var.cluster_version
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access = var.endpoint_public_access
    public_access_cidrs = var.public_access_cidrs
    security_group_ids = var.security_group_ids
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_cluster_policy,
    aws_iam_role_policy_attachment.aws_eks_vpc_resource_controller,
    aws_cloudwatch_log_group.control_plan_log_group
  ]
}

# Cluster OIDC
data "tls_certificate" "cluster_oidc_tls" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "iam_open_id_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc_tls.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.cluster_oidc_tls.url
}

#Cluster oidc assume role
data "aws_iam_policy_document" "cluster_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.iam_open_id_connect.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.iam_open_id_connect.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cluster_oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.cluster_oidc_assume_role_policy.json
  name               = "${var.identifier}-${terraform.workspace}-oidc-role"
}

#NodeGroup Roles, Policies and Policy attachment
resource "aws_iam_role" "node_group_role" {
  name = "${var.identifier}-${terraform.workspace}-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "aws_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "aws_ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

#EKS NodeGroup
resource "aws_eks_node_group" "cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.identifier}-${terraform.workspace}"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.ng_subnet_ids
  capacity_type   = var.ng_capacity_type
  disk_size       = var.ng_disk_size
  ami_type        = var.ng_ami_type
  instance_types  = var.ng_instance_types


  scaling_config {
    desired_size = var.ng_desire_size
    max_size     = var.ng_max_size
    min_size     = var.ng_min_size
  }

  update_config {
    max_unavailable_percentage = var.ng_max_unavailable_percentage
  }

  tags = merge(local.tags, 
    {
      Name = "${var.identifier}-${terraform.workspace}"
    })

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.aws_ec2_container_registry_readonly,
  ]

}