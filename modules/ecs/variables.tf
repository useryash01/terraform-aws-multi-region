variable "target_group_arn" {
  description = "Target Group ARN for the ECS Service"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM Instance Profile for ECS EC2 instances"
  type        = string
}

variable "ecs_sg_id" {
  description = "Security Group ID for ECS instances"
  type        = string
}

variable "private_subnet_1_id" {
  description = "Private Subnet 1 ID"
  type        = string
}

variable "private_subnet_2_id" {
  description = "Private Subnet 2 ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "instance_type" {
  description = "EC2 instance size for the ECS cluster hosts"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of running ECS host instances"
  type        = number
}

variable "max_size" {
  description = "Maximum size of ECS host ASG scaling bounds"
  type        = number
}

variable "min_size" {
  description = "Minimum size of ECS host ASG scaling bounds"
  type        = number
}

variable "logs_kms_key_id" {
  description = "KMS key ARN for encrypting CloudWatch log groups. If null, uses AWS-managed key."
  type        = string
  default     = null
}
