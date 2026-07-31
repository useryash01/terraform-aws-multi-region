module "networking" {

  source = "./modules/networking"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_1 = "10.0.1.0/24"
  public_subnet_2 = "10.0.2.0/24"

  private_subnet_1 = "10.0.3.0/24"
  private_subnet_2 = "10.0.4.0/24"

  environment = var.environment
  common_tags = var.common_tags
}

module "networking_secondary" {
  source = "./modules/networking"

  providers = {
    aws = aws.secondary
  }

  vpc_cidr = "172.16.0.0/16"

  public_subnet_1 = "172.16.1.0/24"
  public_subnet_2 = "172.16.2.0/24"

  private_subnet_1 = "172.16.3.0/24"
  private_subnet_2 = "172.16.4.0/24"

  environment        = var.environment
  common_tags        = var.common_tags
  enable_nat_gateway = false
}

module "security" {

  source = "./modules/security"

  vpc_id = module.networking.vpc_id

  environment = var.environment
  common_tags = var.common_tags
}

module "alb" {

  source = "./modules/alb"

  vpc_id = module.networking.vpc_id

  public_subnet_1_id = module.networking.public_subnet_1_id
  public_subnet_2_id = module.networking.public_subnet_2_id

  alb_sg_id = module.security.alb_sg_id

  environment = var.environment
  common_tags = var.common_tags
}

module "ecs" {

  source = "./modules/ecs"

  target_group_arn = module.alb.target_group_arn

  instance_profile_name = module.security.instance_profile_name

  ecs_sg_id = module.security.ecs_sg_id

  private_subnet_1_id = module.networking.private_subnet_1_id
  private_subnet_2_id = module.networking.private_subnet_2_id

  environment = var.environment
  common_tags = var.common_tags
}

module "rds" {

  source = "./modules/rds"

  vpc_id = module.networking.vpc_id

  ecs_sg_id = module.security.ecs_sg_id

  private_subnet_1_id = module.networking.private_subnet_1_id
  private_subnet_2_id = module.networking.private_subnet_2_id

  environment = var.environment
  common_tags = var.common_tags
}
