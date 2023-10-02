#------------------> EKS-cluster Vars <--------------------#

variable "eks_name" {
    type = string 
    default = "312-eks"     
}
variable "vers" {
    type = string 
    default = "1.26"     
}
variable "subnets" {
    type = list(string)      
}
variable "logs" {
    type = list(string)
    default = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]
}
variable "eks_tag_key" {
    type = string 
    default = "eks-cluster"     
}
variable "eks_tag_value" {
    type = string 
    default = "312"     
}

#--------------------> Add-ons Vars <----------------------#

variable "addons" {
    type = list(string)
    default = [ "vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver" ] 
}
variable "core_dns_timer" {
    type = string 
    default = "1m"     
}
variable "ebs_csi_timer" {
    type = string 
    default = "2m"     
}

#------------------> IAM Roles Vars <----------------------#

variable "asg_list_cluster_role_name" {
  type = string
  default = "EKS_list_clusters"
}
variable "EKS_role_name" {
  type = string
  default = "eks-cluster-role"
}
variable "eks_iam_role_policies" {
  type = list(string)
  default = [ 
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", 
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess", 
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess", 
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", 
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy", 
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController", 
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    ]
  
}

#--------------------> EKS_sgs Vars <----------------------#

variable "vpc_id" {
    type = string  
}
variable "EKS_sg_name" {
  type = string
  default = "eks-sg"
}
variable "EKS_sg_tag" {
  type = string
  default = "eks-sg"
}
variable "EKS_sg_description" {
  type = string
  default = "allow HTTP, HTTPS, SSH traffic"
}
variable "inbound_cidr" {
  type = string
  default = "0.0.0.0/0"
}
variable "eks_sg_ingress_description" {
  type = string
  default = "Allow Node Ports"
}
variable "ports" {
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  default = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
    }
    mysql = {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL"
    }
    kubelet = {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Logs"
    }
    for_kibana = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "for_kibana" #Do more research why it needs all ports. 
    }
  }
}
variable "eks_sg_ingress_from_port" {
  type = string
  default = "30000"
}
variable "eks_sg_ingress_to_port" {
  type = string
  default = "32767"
}
variable "tcp_protocol" {
  type = string
  default = "tcp"
}
variable "eks_sg_rule_type" {
  type = string
  default = "ingress"
}
variable "eks_sg_rule_from_port" {
  type = string
  default = "0"
}
variable "eks_sg_rule_to_port" {
  type = string
  default = "65535"
}
#----------------------> ASG Vars <------------------------#
variable "ASG_desired_capacity" {
  type = string
  default = "4"
}
variable "ASG_max_size" {
  type = string
  default = "4"
}
variable "ASG_min_size" {
  type = string
  default = "2"
}

variable "ASG_name" {
  type = string
  default = "worker-nodes"
}
variable "key_name" {
    type = string
    default = "key"  
}
variable "asg_iam_role_name" {
  type = string
  default = "eks_asg-role"
}
variable "asg_iam_role_policies" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
]  
  
}
variable "node_labels" {
  type        = map(any)
  description = "(Optional) Kubernetes labels to apply to all nodes in the node group."
  default     = {
    key                 = "kubernetes.io/cluster/312-eks"
    value               = "owned"
    propagate_at_launch = true
  }
}
variable "asg_allocation_strategy" {
    type = string
    default = "capacity-optimized"  
}
variable "asg_launch_template_version" {
    type = string
    default = "$Latest"  
}
variable "iam_instance_profile_name" {
    type = string
    default = "eks_self_managed_node_group-instance-profile"  
}
variable "asg_tag_key" {
    type = string
    default = "kubernetes.io/cluster/312-eks"  
}
variable "asg_tag_value" {
    type = string
    default = "owned"  
}
variable "asg_tag_propagate_at_launch" {
    type = bool
    default = true  
}
#--------------> ASG launch template Vars <----------------#

variable "lt_name_prefix" {
    type = string
    default = "worker"  
}
variable "lt_description" {
    type = string
    default = "ec2s asg"  
}
variable "lt_instance_type" {
    type = string
    default = "t3.medium"  
}
variable "lt_instance_shutdown_behavior" {
    type = string
    default = "terminate"  
}

