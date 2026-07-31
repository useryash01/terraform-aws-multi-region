variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_1" {
  description = "CIDR block for Public subnet 1"
  type        = string
}

variable "public_subnet_2" {
  description = "CIDR block for Public subnet 2"
  type        = string
}

variable "private_subnet_1" {
  description = "CIDR block for Private subnet 1"
  type        = string
}

variable "private_subnet_2" {
  description = "CIDR block for Private subnet 2"
  type        = string
}


variable "environment" {
  description = "Deployment Environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision a NAT Gateway"
  type        = bool
  default     = true
}
