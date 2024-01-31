output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.self.id
  precondition {
    condition     = length(aws_vpc.self.id) > 0
    error_message = "The VPC ID Must be non-empty"
  }
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.self.cidr_block
}

output "vpc_default_security_group_id" {
  description = "The ID of the default security group in the VPC"
  value       = aws_vpc.self.default_security_group_id
  precondition {
    condition     = length(aws_vpc.self.default_security_group_id) > 0
    error_message = "The vpc_default_security_group_id ID Must be non-empty"
  }
}