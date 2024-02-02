variable "name_prefix" {
  description = "prefix for the name of the resources"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "Variable length should be 20 characters or less"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region should be in the format eu-north-1"
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