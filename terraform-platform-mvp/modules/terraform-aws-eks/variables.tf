variable "name_prefix" {
  description = "prefix for the name of the resources"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "Variable length should be 20 characters or less"
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]{8,}$", var.vpc_id))
    error_message = "VPC ID should be in the format vpc-xxxxxxxx"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)

  validation {
    condition = alltrue([
    for alias in var.subnet_ids : can(regex("^subnet-[a-z0-9]{8,}$", alias))])
    error_message = "Subnet IDs should be in the format subnet-xxxxxxxx"
  }

  validation {
    condition     = length(var.subnet_ids) >= 2 && length(var.subnet_ids) <= 3
    error_message = "at least 2 and at most 3 subnet IDs are required for HA"
  }
}

variable "instance_types" {
  description = "List of instance types"
  type        = list(string)
  default     = ["t3.small"]
  validation {
    condition = alltrue([
    for alias in var.instance_types : can(regex("^[a-z0-9]+\\.[a-z0-9]+$", alias))])
    error_message = "Instance types should be in the format t3.small"
  }
}

