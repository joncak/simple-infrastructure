variable "name_prefix" {
  description = "prefix for the name of the resources"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "Variable length should be 20 characters or less"
  }
}

variable "cidr_block" {
  description = "value of the CIDR block"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/(\\d|[12]\\d|3[0-2])$", var.cidr_block)) && tonumber(split("/", var.cidr_block)[1]) <= 24
    error_message = "CIDR block should have a subnet mask of /24"
  }
}

variable "azs" {
  description = "availability zones"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2 && length(var.azs) <= 3
    error_message = "at least 2 and at most 3 availability zones are required"
  }
}

variable "private_subnets" {
  description = "list of private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.private_subnets) >= 2 && length(var.private_subnets) <= 3
    error_message = "at least 2 and at most 3 private subnets are required"
  }

}

variable "public_subnets" {
  description = "list of public subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  validation {
    condition     = length(var.public_subnets) >= 2 && length(var.public_subnets) <= 3
    error_message = "at least 2 and at most 3 public subnets are required"
  }
}

variable "enable_nat_gateway" {
  description = "enable NAT gateway"
  type        = bool
  default     = true
}