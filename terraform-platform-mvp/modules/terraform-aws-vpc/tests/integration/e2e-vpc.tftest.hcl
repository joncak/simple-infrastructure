# TODO: On a long term solution i would replace this test to create a helper-ec2-instance and validate the IP_PUBLIC match aws_eip.self.public_ip
provider "aws" {
  region = "eu-north-1"
}

variables {
    name_prefix = "playground"
     azs = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

run "validate_nat_gateway_is_created" {
  command = apply

  assert {
    condition     = aws_nat_gateway.self[0].id != null
    error_message = "Nat gateway should be created"
  }
}