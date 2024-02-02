# TODO: Fix this test on the long term, they are failing because of a bug with terraform test command
provider "aws" {
  region = "eu-north-1"
}

variables {
    name_prefix = "playground"
    azs = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

run "setup-vpc" {
  module {
  source = "../terraform-aws-vpc"
  }
}

run "validate_eks_cluster_is_created" {
  command = apply

  variables {
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnet_ids
  }

  assert {
    condition     = aws_eks_cluster.self.id != null
    error_message = "eks cluster should be created"
  }
}

run "validate_worker_nodes_are_created" {
  command = apply

  variables {
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnet_ids
  }

  assert {
    condition     = aws_eks_node_group.self.id != null
    error_message = "eks cluster should be created"
  }
}