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

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      var.ecs_sg_id
    ]
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-rds-sg"
  })
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.environment}-postgres"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  storage_encrypted = true

  username = "postgres"
  password = var.db_password

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  backup_retention_period = 7

  multi_az = false

  deletion_protection = false

  skip_final_snapshot = true

  tags = merge(var.common_tags, {
    Name = "${var.environment}-postgres"
  })
}
