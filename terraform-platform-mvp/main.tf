
provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source      = "./modules/terraform-aws-vpc"
  name_prefix = var.name_prefix
  azs         = var.azs
}

module "eks" {
  source = "./modules/terraform-aws-eks"
  name_prefix = var.name_prefix
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}