provider "aws" {}

mock_provider "aws" {
  alias = "local"
}

variables {
    name_prefix = "playground"
}

run "validate_default_vpc_is_created" {
  command = plan

 providers = {
    aws = aws.local
  }
  
  assert {
    condition     = aws_vpc.self != null
    error_message = "Default VPC should be created"
  }
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
    var.name_prefix ,
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

# run "validate_default_vpc" {
#   command = apply

#  providers = {
#     aws = aws
#   }

#   assert {
#     condition     = aws_vpc.self.id != null
#     error_message = "Default VPC should be created"
#   }
# }