variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}

variable "alb_sg_id" {
  description = "Security Group ID for the Application Load Balancer"
  type        = string
}

variable "public_subnet_1_id" {
  description = "Public subnet 1 ID"
  type        = string
}

variable "public_subnet_2_id" {
  description = "Public subnet 2 ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
