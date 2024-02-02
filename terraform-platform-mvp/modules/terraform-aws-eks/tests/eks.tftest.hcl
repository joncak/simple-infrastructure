provider "aws" {}

mock_provider "aws" {
    alias = "local"
}

variables {
  name_prefix = "playground"
  vpc_id = "vpc-12345678"
  subnet_ids = ["subnet-xxxxxxx1","subnet-xxxxxxx2","subnet-xxxxxxx3"]
}

run "long_name_should_fail" {
  command = plan

  providers = {
    aws = aws.local
  }

  variables {
    name_prefix = "this_is_a_very_long_name"
  }
  expect_failures = [
    var.name_prefix,
  ]
 }

run "bad_vpc_id_should_fail" {
  command = plan

  providers = {
    aws = aws.local
  }

  variables {
    vpc_id = "this_is_not_a_vpc_id"
  }

  expect_failures = [
    var.vpc_id,
  ]
}

run "bad_subnet_id_should_fail" {
  command = plan

  providers = {
    aws = aws.local
  }

  variables {
    subnet_ids = ["this_is_not_a_subnet_id"]
  }

  expect_failures = [
    var.subnet_ids,
  ]
}

run "bad_instance_types_should_fail" {
  command = plan

  providers = {
    aws = aws.local
  }

  variables {
    instance_types = ["this_is_not_a_instance_type"]
  }

  expect_failures = [
    var.instance_types,
  ]
}

# run "at_least_two_private_subnets_should_be_created" {
#   command = plan

#   providers = {
#     aws = aws.local
#   }

#   assert {
#     condition     = length(aws_subnet.private) >= 2
#     error_message = "at least 2 private subnets should be created"

#   }
# }

# run "at_least_two_public_subnets_should_be_created" {
#   command = plan

#   providers = {
#     aws = aws.local
#   }

#   assert {
#     condition     = length(aws_subnet.public) >= 2
#     error_message = "at least 2 public subnets should be created"

#   }
# }
# run "number_of_private_subnet_should_match" {
#   command = plan

#   variables {
#     private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
#   }

#   providers = {
#     aws = aws.local
#   }

#   assert {
#     condition     = length(aws_subnet.private) == 2
#     error_message = "incorrect number of private subnets"

#   }
# }

# run "at_least_two_azs_should_be_provided" {
#   command = plan

#   providers = {
#     aws = aws.local
#   }

#   variables {
#     azs = ["eu-west-1a"]
#   }

#   expect_failures = [
#     var.azs,
#   ]
# }

# run "validate_eip_is_attached_to_nat_gateway" {
#   command = apply

#   providers = {
#     aws = aws.local
#   }

#   variables {
#     enable_nat_gateway = true
#   }

#   assert {
#     condition     = aws_eip.self[0].id != null
#     error_message = "EIP should be created"
#   }

#   assert {
#     condition     = aws_nat_gateway.self[0].allocation_id == aws_eip.self[0].id
#     error_message = "EIP should be attached to NAT gateway"
#   }
# }