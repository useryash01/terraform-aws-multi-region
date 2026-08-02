environment = "dev"
aws_region  = "ap-south-1"

# --- Networking Primary ---
vpc_cidr_primary           = "10.10.0.0/16"
public_subnet_1_primary    = "10.10.1.0/24"
public_subnet_2_primary    = "10.10.2.0/24"
private_subnet_1_primary   = "10.10.3.0/24"
private_subnet_2_primary   = "10.10.4.0/24"
enable_nat_gateway_primary = false

# --- Networking Secondary ---
vpc_cidr_secondary           = "172.16.0.0/16"
public_subnet_1_secondary    = "172.16.1.0/24"
public_subnet_2_secondary    = "172.16.2.0/24"
private_subnet_1_secondary   = "172.16.3.0/24"
private_subnet_2_secondary   = "172.16.4.0/24"
enable_nat_gateway_secondary = false

# --- ECS Capacity ---
ecs_instance_type    = "t3.micro"
ecs_desired_capacity = 1
ecs_max_size         = 2
ecs_min_size         = 1

# --- ECS Auto Scaling ---
ecs_min_tasks        = 1
ecs_max_tasks        = 2
ecs_cpu_target_value = 70

# --- RDS Capacity ---
rds_instance_class = "db.t3.micro"

# --- Tags ---
common_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
