#-----> VPC related 

output "vpc_id" {
  value = aws_vpc.eks-vpc.id
}
output "subnet_name" {
    value = var.subnet-name
}
output "public_subnet_for_eks_ec2" {
    value = aws_subnet.subnet[3].id  
}

#-----> Public Subnets [3]-[5]

output "public_sub_3" {
  value = aws_subnet.subnet[3].id
}
output "public_sub_4" {
  value = aws_subnet.subnet[4].id
}
output "public_sub_5" {
  value = aws_subnet.subnet[5].id
}

#-----> private subnets [0]-[2]

output "private_sub_0" {
    value = aws_subnet.subnet[0].id
}
output "private_sub_1" {
    value = aws_subnet.subnet[1].id
}
output "private_sub_2" {
    value = aws_subnet.subnet[2].id
}

#-----> Nat GW

output "nat_gateway_for_public_sub" {
    value = aws_subnet.subnet[3].id
}

#-----> Multi AZs nodes

output "azs" {
    value = var.azs  
}