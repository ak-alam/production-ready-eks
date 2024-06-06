#########################################
#kubeproxy
#coreDNS
#vpcCNI
#EBS CSI Driver
#EFS CSI Driver

# resource "aws_eks_addon" "example" {
#  for_each = { for addon in var.addons: addon.addon_name => addon }

#   cluster_name                = aws_eks_cluster.eks_cluster.name
#   addon_name                  = each.value.addon_name
#   addon_version               = each.value.addon_version
#   resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
# }
