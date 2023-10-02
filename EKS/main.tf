module "my_vpc" {           
  source = "./modules/VPC"  
}

module "EKS" {
    source = "./modules/EKS"
    subnets = [module.my_vpc.public_sub_3, module.my_vpc.public_sub_4, module.my_vpc.public_sub_5]
    vpc_id = module.my_vpc.vpc_id
}

