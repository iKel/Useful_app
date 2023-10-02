#------------------------> AWS <---------------------------#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
#----------------------------------------------------------#

#----------------------> Kubernetes <----------------------#

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  depends_on = [ module.EKS.eks_cluster]
}
data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
  depends_on = [ module.EKS.cluster_name ]
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
#----------------------------------------------------------#

#--------------------------> HELM <------------------------#

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}
#----------------------------------------------------------#
