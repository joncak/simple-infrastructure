provider "aws" {}

mock_provider "aws" {
    alias = "local"
}

variables {
  name_prefix = "playground"
  azs         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
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

run "bad_cird_block_should_fail" {
  command = plan

  providers = {
    aws = aws.local
  }

  variables {
    cidr_block = "10.0.0.0/25"
  }

  expect_failures = [
    var.cidr_block,
  ]
}

run "at_least_two_private_subnets_should_be_created" {
  command = plan

  providers = {
    aws = aws.local
  }

  assert {
    condition     = length(aws_subnet.private) >= 2
    error_message = "at least 2 private subnets should be created"

  }
}

run "at_least_two_public_subnets_should_be_created" {
  command = plan

  providers = {
    aws = aws.local
  }

  assert {
    condition     = length(aws_subnet.public) >= 2
    error_message = "at least 2 public subnets should be created"

  }
}
run "number_of_private_subnet_should_match" {
  command = plan

  variables {
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  providers = {
    aws = aws.local
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "incorrect number of private subnets"

  }
}

run "at_least_two_azs_should_be_provided" {
  command = plan

  providers = {
    aws = aws.local
  }

  variables {
    azs = ["eu-west-1a"]
  }

  expect_failures = [
    var.azs,
  ]
}

run "validate_eip_is_attached_to_nat_gateway" {
  command = apply

  providers = {
    aws = aws.local
  }

  variables {
    enable_nat_gateway = true
  }

  assert {
    condition     = aws_eip.self[0].id != null
    error_message = "EIP should be created"
  }

  assert {
    condition     = aws_nat_gateway.self[0].allocation_id == aws_eip.self[0].id
    error_message = "EIP should be attached to NAT gateway"
  }
}