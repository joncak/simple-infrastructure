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

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}