output "arn" {
    value = aws_iam_role.eks_asg.arn      
}
output "cluster-name" {
    value = aws_eks_cluster.eks_cluster_312.name 
}
output "cluster-endpoint" {
    value = aws_eks_cluster.eks_cluster_312.endpoint
}
output "cluster_security_group_id" {
    value   = aws_eks_cluster.eks_cluster_312.vpc_config[0].cluster_security_group_id
}
output "eks_cluster" {
    value = aws_eks_cluster.eks_cluster_312
}
output "autoscaling_group" {
    value = aws_autoscaling_group.asg
}