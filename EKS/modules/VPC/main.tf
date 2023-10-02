#--------------------------> VPC <-------------------------#

resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_tag
  }
}

#-------------------------> Subnets <----------------------#

resource "aws_subnet" "subnet" {
  count = length(var.subnet-name)
  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = var.subs_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  availability_zone = element(var.azs, count.index % local.num_azs)

  tags = {
    Name = var.subnet-name[count.index]
  }
}
locals {
  num_azs = length(var.azs)
}

#---------------> RTs, IGW, NAT_gw, EIP  <------------------#

resource "aws_route_table" "eks-rt_public" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = var.rt_public_tag
  }
}
resource "aws_route_table" "eks-rt_nat" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = var.rt_nat_tag
  }
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.eks-rt_public.id
  destination_cidr_block = var.igw_cidr_block
  gateway_id             = aws_internet_gateway.eks_igw.id
} 

resource "aws_route" "internet_gateway_route-0" {
  route_table_id         = aws_route_table.eks-rt_nat.id
  destination_cidr_block = var.igw_cidr_block
  gateway_id             = aws_nat_gateway.nat_gateway.id
}

       # Route Table associations for Public Subnets #

resource "aws_route_table_association" "subnet_association_pub-3" {
  subnet_id       = aws_subnet.subnet[3].id
  route_table_id  = aws_route_table.eks-rt_public.id
}
resource "aws_route_table_association" "subnet_association_pub-4" {
  subnet_id = aws_subnet.subnet[4].id
  route_table_id = aws_route_table.eks-rt_public.id
}
resource "aws_route_table_association" "subnet_association_pub-5" {
  subnet_id = aws_subnet.subnet[5].id
  route_table_id = aws_route_table.eks-rt_public.id
}

       #  Route Table associations for Private Subnets #

resource "aws_route_table_association" "subnet_association_priv-0" {
  subnet_id      = aws_subnet.subnet[0].id
  route_table_id = aws_route_table.eks-rt_nat.id
}
resource "aws_route_table_association" "subnet_association_priv-1" {
  subnet_id      = aws_subnet.subnet[1].id
  route_table_id = aws_route_table.eks-rt_nat.id
}
resource "aws_route_table_association" "subnet_association_priv-2" {
  subnet_id      = aws_subnet.subnet[2].id
  route_table_id = aws_route_table.eks-rt_nat.id
}

#---------------------> IGW, NAT_gw, EIP <------------------#

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks-vpc.id
  
  tags = {
    Name = var.eks_igw_tag
  }
}
resource "aws_eip" "nat_eip" {
  domain = var.eks_eip_domain

  tags = {
    Name = var.eks_eip_tag
  }
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet[3].id

  tags = {
    Name = var.nat_gw_tag
  }
}