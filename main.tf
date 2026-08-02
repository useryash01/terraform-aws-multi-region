module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr_primary
  public_subnet_1    = var.public_subnet_1_primary
  public_subnet_2    = var.public_subnet_2_primary
  private_subnet_1   = var.private_subnet_1_primary
  private_subnet_2   = var.private_subnet_2_primary
  enable_nat_gateway = var.enable_nat_gateway_primary

  environment = var.environment
  common_tags = var.common_tags
}

module "networking_secondary" {
  source = "./modules/networking"

  providers = {
    aws = aws.secondary
  }

  vpc_cidr           = var.vpc_cidr_secondary
  public_subnet_1    = var.public_subnet_1_secondary
  public_subnet_2    = var.public_subnet_2_secondary
  private_subnet_1   = var.private_subnet_1_secondary
  private_subnet_2   = var.private_subnet_2_secondary
  enable_nat_gateway = var.enable_nat_gateway_secondary

  environment = var.environment
  common_tags = var.common_tags
}

module "security" {
  source = "./modules/security"

  vpc_id = module.networking.vpc_id

  environment = var.environment
  common_tags = var.common_tags
}

module "alb" {
  source = "./modules/alb"

  vpc_id             = module.networking.vpc_id
  public_subnet_1_id = module.networking.public_subnet_1_id
  public_subnet_2_id = module.networking.public_subnet_2_id
  alb_sg_id          = module.security.alb_sg_id
  certificate_arn    = var.certificate_arn
  alb_logs_bucket    = var.alb_logs_bucket

  environment = var.environment
  common_tags = var.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  target_group_arn      = module.alb.target_group_arn
  instance_profile_name = module.security.instance_profile_name
  ecs_sg_id             = module.security.ecs_sg_id
  private_subnet_1_id   = module.networking.private_subnet_1_id
  private_subnet_2_id   = module.networking.private_subnet_2_id
  logs_kms_key_id       = var.logs_kms_key_id

  instance_type    = var.ecs_instance_type
  desired_capacity = var.ecs_desired_capacity
  max_size         = var.ecs_max_size
  min_size         = var.ecs_min_size

  # --- Auto Scaling (Phase 4) ---
  ecs_min_tasks        = var.ecs_min_tasks
  ecs_max_tasks        = var.ecs_max_tasks
  ecs_cpu_target_value = var.ecs_cpu_target_value

  environment = var.environment
  common_tags = var.common_tags
}

module "rds" {
  source = "./modules/rds"

  vpc_id              = module.networking.vpc_id
  ecs_sg_id           = module.security.ecs_sg_id
  private_subnet_1_id = module.networking.private_subnet_1_id
  private_subnet_2_id = module.networking.private_subnet_2_id
  instance_class      = var.rds_instance_class
  rds_kms_key_id      = var.rds_kms_key_id

  environment = var.environment
  common_tags = var.common_tags
}

# --- CodeDeploy for ECS Blue/Green Deployment (Phase 3) ---

module "codedeploy" {
  source = "./modules/codedeploy"

  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name

  production_listener_arn = module.alb.https_listener_arn
  test_listener_arn       = module.alb.test_listener_arn

  blue_target_group_name       = module.alb.target_group_name
  green_target_group_name      = module.alb.green_target_group_name
  blue_target_group_arn_suffix = module.alb.target_group_arn_suffix
  alb_arn_suffix               = module.alb.alb_arn_suffix

  environment = var.environment
  common_tags = var.common_tags
}
