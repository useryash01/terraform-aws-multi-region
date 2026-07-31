environment = "test"
aws_region  = "ap-south-1"

# --- Networking Primary ---
vpc_cidr_primary           = "10.20.0.0/16"
public_subnet_1_primary    = "10.20.1.0/24"
public_subnet_2_primary    = "10.20.2.0/24"
private_subnet_1_primary   = "10.20.3.0/24"
private_subnet_2_primary   = "10.20.4.0/24"
enable_nat_gateway_primary = true

# --- Networking Secondary ---
vpc_cidr_secondary           = "172.16.0.0/16"
public_subnet_1_secondary    = "172.16.1.0/24"
public_subnet_2_secondary    = "172.16.2.0/24"
private_subnet_1_secondary   = "172.16.3.0/24"
private_subnet_2_secondary   = "172.16.4.0/24"
enable_nat_gateway_secondary = false

# --- ECS Capacity ---
ecs_instance_type    = "t3.small"
ecs_desired_capacity = 2
ecs_max_size         = 3
ecs_min_size         = 2

# --- RDS Capacity ---
rds_instance_class = "db.t3.micro"

# --- Tags ---
common_tags = {
  Environment = "test"
  ManagedBy   = "Terraform"
}
