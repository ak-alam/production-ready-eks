variable "addons" {
  description = "EKS addons"
  type = list(object({
    addon_name = string
    addon_version = string
    resolve_conflicts_on_update = string
    # service_account_role_arn = string
  }))
  default = [
    {
      addon_name = "coredns"
      addon_version = "v1.10.1-eksbuild.7"
      resolve_conflicts_on_update = "PRESERVE"
    }
  ]
 }