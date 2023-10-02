#-------------> nginx ingress-controller <-----------------#

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"
  version = "2.2.2"
  depends_on = [ aws_eks_cluster.eks_cluster_312, aws_autoscaling_group.asg ]
}
#----------------------------------------------------------#

#--------------------> k8s commands <----------------------#

resource "null_resource" "cmds_exec" {
  depends_on = [ module.nginx-controller ]
  provisioner "local-exec" {
    command = "./scripts/k8s_cmds.sh" 
  }
}

#----------------------------------------------------------#
