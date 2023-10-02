#---------------------------------------------------------#
#                      EKS-cluster creation               #
#---------------------------------------------------------#
resource "aws_eks_cluster" "eks_cluster_312" {
  name     = var.eks_name
  role_arn = aws_iam_role.EKS_role.arn
  version  = var.vers
  enabled_cluster_log_types = var.logs
  
  tags = {
    key = var.eks_tag_key
    value = var.eks_tag_value
  }
  vpc_config {
    subnet_ids = var.subnets
    security_group_ids = [aws_security_group.eks-sg.id]
  }
}
#---------------------------------------------------------#-----#
resource "aws_eks_addon" "vpc_cni" {                      #   A #
  cluster_name = aws_eks_cluster.eks_cluster_312.name     #   D #
  addon_name   = var.addons[0]                            #   D #             
}                                                         #   O #
resource "aws_eks_addon" "kube-proxy" {                   #   N #
  cluster_name = aws_eks_cluster.eks_cluster_312.name     #   S #
  addon_name   = var.addons[1]                            #-----#
}                                                         #                                                                                                            
resource "aws_eks_addon" "core_dns" {                     #
  cluster_name = aws_eks_cluster.eks_cluster_312.name     #
  addon_name   = var.addons[2]                            #
  depends_on = [ module.nginx-controller ]                #
  timeouts {                                              #
    create = var.core_dns_timer                           #                           
  }                                                       #
}                                                         #
resource "aws_eks_addon" "aws-ebs-csi-driver" {           #
  cluster_name = aws_eks_cluster.eks_cluster_312.name     #
  addon_name   = var.addons[3]                            #
  depends_on = [ module.nginx-controller ]                #
  timeouts {                                              #
    create = var.ebs_csi_timer                            #                   
  }                                                       #
}                                                         #
#---------------------------------------------------------#

#------> EKS-cluster IAM_Role creation+attachment <--------#

resource "aws_iam_role" "EKS_role" {
  name = var.EKS_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = var.eks_iam_role_policies
}

/*resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKS_role.name
}*/
#----------------------> EKS_sgs <------------------------#

resource "aws_security_group" "eks-sg" {
  name        = var.EKS_sg_name
  description = var.EKS_sg_description
  vpc_id = var.vpc_id
  tags = {
    Name = var.EKS_sg_tag
  }
  ingress {
    description = var.eks_sg_ingress_description
    from_port   = var.eks_sg_ingress_from_port
    to_port     = var.eks_sg_ingress_to_port  
    protocol    = var.tcp_protocol
    cidr_blocks = [var.inbound_cidr]  
  }
  dynamic "ingress" {
    for_each = var.ports

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [var.inbound_cidr]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.ports

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = [var.inbound_cidr]
      description = egress.value.description
    }
  }
}
resource "aws_security_group_rule" "allow_inbound_to_source_sg" {
  type        = var.eks_sg_rule_type
  from_port   = var.eks_sg_rule_from_port
  to_port     = var.eks_sg_rule_to_port
  protocol    = var.tcp_protocol
  cidr_blocks = [var.inbound_cidr]
  security_group_id = aws_eks_cluster.eks_cluster_312.vpc_config[0].cluster_security_group_id
}

#---------------------------------------------------------#


#---------------------------------------------------------#
#                       ASG creation                      #
#---------------------------------------------------------#
resource "aws_autoscaling_group" "asg" {
  depends_on = [ kubernetes_config_map.aws-auth ]
  name = var.ASG_name
  capacity_rebalance = true
  desired_capacity  = var.ASG_desired_capacity
  max_size          = var.ASG_max_size
  min_size          = var.ASG_min_size
  vpc_zone_identifier  = var.subnets

  mixed_instances_policy {          # mixed instance allows to use o-demand+spot instances  
    instances_distribution {        # within one ASG
      on_demand_base_capacity                  = 3
      on_demand_percentage_above_base_capacity = 75
      spot_allocation_strategy                 = var.asg_allocation_strategy
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.self_managed_nodes.id
        version = var.asg_launch_template_version
      }
    } 
  }
  tag {
    key   = var.asg_tag_key
    value = var.asg_tag_value
    propagate_at_launch = var.asg_tag_propagate_at_launch
  }
}
#------ ASG IAM_Role creation+attachment------------------#

resource "aws_iam_role" "eks_asg" {
  name               = var.asg_iam_role_name
  assume_role_policy = jsonencode({
    Version: "2012-10-17"
    Statement = [
      {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal =  {
        Service = "ec2.amazonaws.com"
        }      
      }
    ]
  })
  tags = var.node_labels
  managed_policy_arns = var.asg_iam_role_policies
}
        #-----> Inline Policy to allow user_data to list clusters
resource "aws_iam_role_policy" "asg_role_policy" {
  name = var.asg_list_cluster_role_name
  role = aws_iam_role.eks_asg.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:ListClusters"]
        Resource = ["*"] 
      }
    ]
  })
}
    
resource "aws_iam_instance_profile" "eks_self_managed_node_group" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.eks_asg.name
  tags = var.node_labels
}
#----------------ASG launch template----------------------#
resource "aws_launch_template" "self_managed_nodes" {
  name_prefix = var.lt_name_prefix
  description = var.lt_description
  instance_initiated_shutdown_behavior = var.lt_instance_shutdown_behavior
  instance_type          = var.lt_instance_type
  image_id               = data.aws_ami.amazon_linux_2.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.eks-sg.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_self_managed_node_group.arn
  }
  user_data = base64encode(templatefile("./scripts/user-data.sh", {
    cluster_name = aws_eks_cluster.eks_cluster_312.name
    node_labels  = var.node_labels
  }))
  tags = var.node_labels 
}
#---------------------------------------------------------#
