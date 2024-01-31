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