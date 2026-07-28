variable "aws_region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
