variable "aws_region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, test, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

# --- Networking Parameters ---
variable "vpc_cidr_primary" {
  description = "VPC CIDR block for primary region"
  type        = string
}

variable "public_subnet_1_primary" {
  description = "Public subnet 1 CIDR for primary region"
  type        = string
}

variable "public_subnet_2_primary" {
  description = "Public subnet 2 CIDR for primary region"
  type        = string
}

variable "private_subnet_1_primary" {
  description = "Private subnet 1 CIDR for primary region"
  type        = string
}

variable "private_subnet_2_primary" {
  description = "Private subnet 2 CIDR for primary region"
  type        = string
}

variable "enable_nat_gateway_primary" {
  description = "Enable NAT gateway for primary region"
  type        = bool
  default     = true
}

variable "vpc_cidr_secondary" {
  description = "VPC CIDR block for secondary region"
  type        = string
}

variable "public_subnet_1_secondary" {
  description = "Public subnet 1 CIDR for secondary region"
  type        = string
}

variable "public_subnet_2_secondary" {
  description = "Public subnet 2 CIDR for secondary region"
  type        = string
}

variable "private_subnet_1_secondary" {
  description = "Private subnet 1 CIDR for secondary region"
  type        = string
}

variable "private_subnet_2_secondary" {
  description = "Private subnet 2 CIDR for secondary region"
  type        = string
}

variable "enable_nat_gateway_secondary" {
  description = "Enable NAT gateway for secondary region"
  type        = bool
  default     = false
}

# --- ECS EC2 Host Parameters ---
variable "ecs_instance_type" {
  description = "EC2 instance size for the ECS cluster hosts"
  type        = string
  default     = "t3.micro"
}

variable "ecs_desired_capacity" {
  description = "Desired number of running ECS host instances"
  type        = number
  default     = 2
}

variable "ecs_max_size" {
  description = "Maximum size of ECS host ASG scaling bounds"
  type        = number
  default     = 4
}

variable "ecs_min_size" {
  description = "Minimum size of ECS host ASG scaling bounds"
  type        = number
  default     = 2
}

# --- ECS Service Auto Scaling (Phase 4) ---
variable "ecs_min_tasks" {
  description = "Minimum number of ECS tasks for auto scaling"
  type        = number
  default     = 2
}

variable "ecs_max_tasks" {
  description = "Maximum number of ECS tasks for auto scaling"
  type        = number
  default     = 6
}

variable "ecs_cpu_target_value" {
  description = "Target CPU utilization percentage for ECS auto scaling"
  type        = number
  default     = 70
}

# --- RDS Parameters ---
variable "rds_instance_class" {
  description = "Instance size class for RDS PostgreSQL database"
  type        = string
  default     = "db.t3.micro"
}

# --- Security / Encryption Parameters ---
variable "certificate_arn" {
  description = "ACM certificate ARN for the ALB HTTPS listener"
  type        = string
  default     = ""
}

variable "alb_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = ""
}

variable "logs_kms_key_id" {
  description = "KMS key ARN for encrypting CloudWatch log groups. If null, uses AWS-managed key."
  type        = string
  default     = null
}

variable "rds_kms_key_id" {
  description = "KMS key ARN for RDS storage encryption and Performance Insights. If null, uses AWS-managed key."
  type        = string
  default     = null
}
