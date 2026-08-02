variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "production_listener_arn" {
  description = "ARN of the ALB production traffic listener (HTTPS/443)"
  type        = string
}

variable "test_listener_arn" {
  description = "ARN of the ALB test traffic listener (8443)"
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue (primary) target group"
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green (secondary) target group"
  type        = string
}

variable "blue_target_group_arn_suffix" {
  description = "ARN suffix of the blue target group for CloudWatch dimensions"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB for CloudWatch dimensions"
  type        = string
}
