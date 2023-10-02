#-----------------------> aws-auth <-----------------------#

resource "null_resource" "timer" {
  depends_on = [ aws_eks_cluster.eks_cluster_312 ]
  provisioner "local-exec" {
    command = var.auth_timer
  }
}
resource "kubernetes_config_map" "aws-auth" {
  depends_on = [ null_resource.timer]
  metadata {
    name      = var.auth_name
    namespace = var.auth_namespace
  }
  data = {
    "mapRoles" = <<EOT
- rolearn: ${aws_iam_role.eks_asg.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOT
  }
}

#----------------------------------------------------------#

#--------------------> aws-auth vars <---------------------#

variable "auth_name" {
  type = string
  default = "aws-auth"
}
variable "auth_namespace" {
  type = string
  default = "kube-system"
}
variable "auth_timer" {
  type = string
  default = "sleep 120"
}
#----------------------------------------------------------#
