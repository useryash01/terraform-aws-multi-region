output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = module.alb.alb_dns
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = module.ecs.ecs_cluster_name
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds.rds_endpoint
}

# --- Phase 3+4 Outputs ---

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = module.ecs.ecs_service_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.ecs.ecr_repository_url
}

output "codedeploy_app_name" {
  description = "CodeDeploy Application Name"
  value       = module.codedeploy.codedeploy_app_name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy Deployment Group Name"
  value       = module.codedeploy.codedeploy_deployment_group_name
}
