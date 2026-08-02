# --- CodeDeploy Application for ECS Blue/Green Deployment ---

resource "aws_codedeploy_app" "ecs" {
  compute_platform = "ECS"
  name             = "${var.environment}-ecs-deploy"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-codedeploy-app"
  })
}

# --- IAM Role for CodeDeploy ---

resource "aws_iam_role" "codedeploy" {
  name = "${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"

      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-codedeploy-role"
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# --- CloudWatch Alarm for Deployment Health ---

resource "aws_cloudwatch_metric_alarm" "deployment_health" {
  alarm_name          = "${var.environment}-ecs-deployment-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Triggers CodeDeploy rollback if no healthy ECS tasks for 5 minutes"
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup  = var.blue_target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-deployment-health-alarm"
  })
}

# --- CodeDeploy Deployment Group ---

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name               = aws_codedeploy_app.ecs.name
  deployment_group_name  = "${var.environment}-ecs-dg"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.production_listener_arn]
      }

      test_traffic_route {
        listener_arns = [var.test_listener_arn]
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.deployment_health.alarm_name]
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-codedeploy-dg"
  })
}
