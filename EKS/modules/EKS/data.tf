data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.26-v20230711"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}
data "aws_key_pair" "key" {
  key_name = var.key_name
  
}