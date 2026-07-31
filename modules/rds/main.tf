resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_secret" {
  name_prefix             = "${var.environment}-db-credentials-"
  description             = "PostgreSQL database credentials"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.db_password.result
  })
}

resource "aws_db_subnet_group" "main" {

  name = "${var.environment}-db-subnet-group"

  subnet_ids = [
    var.private_subnet_1_id,
    var.private_subnet_2_id
  ]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-db-subnet-group"
  })
}

resource "aws_security_group" "rds_sg" {

  name        = "${var.environment}-rds-sg"
  description = "Security group for PostgreSQL RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow PostgreSQL traffic from ECS instances"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"

    security_groups = [
      var.ecs_sg_id
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-rds-sg"
  })
}

# --- IAM Role for RDS Enhanced Monitoring ---
resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"

      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-rds-monitoring-role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.environment}-postgres"

  engine         = "postgres"
  engine_version = "15"

  instance_class = var.instance_class

  allocated_storage = 20
  storage_type      = "gp3"

  storage_encrypted = true
  kms_key_id        = var.rds_kms_key_id

  username = jsondecode(aws_secretsmanager_secret_version.db_secret_val.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_secret_val.secret_string)["password"]

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  backup_retention_period = 7

  multi_az = true

  deletion_protection = true

  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  iam_database_authentication_enabled = true

  copy_tags_to_snapshot = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.rds_kms_key_id

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  tags = merge(var.common_tags, {
    Name = "${var.environment}-postgres"
  })
}
