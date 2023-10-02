#------------------------> VPC vars <----------------------#

variable "vpc_cidr_block" {
    type = string
    default = "172.16.0.0/16" 
}
variable "vpc_tag" {
    type = string
    default = "eks-vpc"
}

#---------------------> Subnet vars <----------------------#

variable "subs_cidr_blocks" {
  type    = list(string)
  default = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24", "172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
}
variable "subnet-name" {
    type  = list(string)
    default = ["private_subnet-1", "private_subnet-2", "private_subnet-3", "public_subnet-1", "public_subnet-2", "public_subnet-3"]
}
variable "azs" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

#-----------------------> RTs vars <-----------------------#

variable "igw_cidr_block" {
    type = string
    default = "0.0.0.0/0"
}
variable "rt_public_tag" {
    type = string
    default = "eks-rt_public"
}
variable "rt_nat_tag" {
    type = string
    default = "eks-rt_nat"
}

#-----------------> IGW, NAT_gw, EIP vars <----------------#
variable "eks_igw_tag" {
    type = string
    default = "eks-igw"
}
variable "eks_eip_domain" {
    type = string
    default = "vpc"
}
variable "eks_eip_tag" {
    type = string
    default = "NATGatewayEIP"
}
variable "nat_gw_tag" {
    type = string
    default = "NATGateway"
}
