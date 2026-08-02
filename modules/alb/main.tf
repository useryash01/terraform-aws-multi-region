resource "aws_lb" "main" {

  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_sg_id
  ]

  subnets = [
    var.public_subnet_1_id,
    var.public_subnet_2_id
  ]

  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = var.alb_logs_bucket
    prefix  = "${var.environment}-alb"
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-alb"
  })
}

# --- Blue Target Group (Primary) ---
resource "aws_lb_target_group" "ecs_tg" {

  name        = "${var.environment}-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ecs-tg"
  })
}

# --- Green Target Group (CodeDeploy Blue/Green) ---
resource "aws_lb_target_group" "ecs_tg_green" {

  name        = "${var.environment}-ecs-tg-green"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ecs-tg-green"
  })
}

# --- Production HTTPS Listener ---
resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-https-listener"
  })
}

# --- HTTP → HTTPS Redirect ---
resource "aws_lb_listener" "http_redirect" {

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-http-redirect-listener"
  })
}

# --- Test Traffic Listener (CodeDeploy Blue/Green Validation) ---
resource "aws_lb_listener" "test" {

  load_balancer_arn = aws_lb.main.arn
  port              = 8443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg_green.arn
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-test-listener"
  })
}
