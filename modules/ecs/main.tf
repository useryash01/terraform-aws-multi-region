data "aws_region" "current" {}

# --- ECR Repository ---

resource "aws_ecr_repository" "app" {
  name                 = "${var.environment}-app"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-app-ecr"
  })
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 20 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 20
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {

  name = "${var.environment}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ecs-cluster"
  })
}

# --- ECS Task Definition ---

resource "aws_ecs_task_definition" "app" {

  family                   = "${var.environment}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.environment}-task-definition"
  })
}

# --- ECS Service ---

resource "aws_ecs_service" "app_service" {

  name            = "${var.environment}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = var.ecs_min_tasks
  launch_type   = "EC2"

  # CodeDeploy manages Blue/Green deployments
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets = [
      var.private_subnet_1_id,
      var.private_subnet_2_id
    ]

    security_groups = [
      var.ecs_sg_id
    ]
  }

  load_balancer {

    target_group_arn = var.target_group_arn

    container_name = "nginx"

    container_port = 80
  }

  # Spread tasks across AZs for high availability
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  depends_on = [
    aws_autoscaling_group.ecs_asg
  ]

  # CodeDeploy manages task_definition and load_balancer after initial creation.
  # Autoscaler manages desired_count.
  lifecycle {
    ignore_changes = [task_definition, load_balancer, desired_count]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-app-service"
  })
}

# --- EC2 Launch Template ---

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_template" {

  name_prefix = "${var.environment}-ecs-template-"

  image_id = data.aws_ssm_parameter.ecs_ami.value

  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {

    associate_public_ip_address = false

    security_groups = [
      var.ecs_sg_id
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted   = true
      volume_type = "gp3"
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ecs-template"
  })
}

# --- Auto Scaling Group for EC2 Instances ---

resource "aws_autoscaling_group" "ecs_asg" {

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  health_check_type = "EC2"

  force_delete = true

  vpc_zone_identifier = [
    var.private_subnet_1_id,
    var.private_subnet_2_id
  ]

  launch_template {

    id = aws_launch_template.ecs_template.id

    version = "$Latest"
  }

  tag {

    key = "Name"

    value = "${var.environment}-ecs-instance"

    propagate_at_launch = true
  }
}

# --- CloudWatch Log Group ---

resource "aws_cloudwatch_log_group" "ecs_logs" {

  name = "/ecs/${var.environment}"

  retention_in_days = var.log_retention_days
  kms_key_id        = var.logs_kms_key_id

  tags = merge(var.common_tags, {
    Name = "/ecs/${var.environment}"
  })
}

# ─────────────────────────────────────────────────────
# Phase 4: ECS Service Auto Scaling
# ─────────────────────────────────────────────────────

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.ecs_max_tasks
  min_capacity       = var.ecs_min_tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# --- CPU Target Tracking Policy ---
resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.environment}-ecs-cpu-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# --- Memory Target Tracking Policy ---
resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "${var.environment}-ecs-memory-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
