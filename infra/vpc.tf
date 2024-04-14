data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zone_list   = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnet_cidr_list  = [cidrsubnet(var.vpc_cidr, 7, 24), cidrsubnet(var.vpc_cidr, 7, 25), cidrsubnet(var.vpc_cidr, 7, 26)]
  private_subnet_cidr_list = [cidrsubnet(var.vpc_cidr, 4, 0), cidrsubnet(var.vpc_cidr, 4, 1), cidrsubnet(var.vpc_cidr, 4, 2)]
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "3.18.1"
  name               = var.name
  cidr               = var.vpc_cidr
  enable_nat_gateway = true
  single_nat_gateway = true
  azs                = local.availability_zone_list
  private_subnets    = local.private_subnet_cidr_list
  public_subnets     = local.public_subnet_cidr_list
}