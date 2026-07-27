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
