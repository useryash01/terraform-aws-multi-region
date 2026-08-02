output "alb_dns" {
  value = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB for CloudWatch metric dimensions"
  value       = aws_lb.main.arn_suffix
}

# --- Blue (Primary) Target Group ---
output "target_group_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}

output "target_group_name" {
  description = "Name of the blue (primary) target group"
  value       = aws_lb_target_group.ecs_tg.name
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the blue target group for CloudWatch"
  value       = aws_lb_target_group.ecs_tg.arn_suffix
}

# --- Green Target Group ---
output "green_target_group_arn" {
  description = "ARN of the green target group for CodeDeploy Blue/Green"
  value       = aws_lb_target_group.ecs_tg_green.arn
}

output "green_target_group_name" {
  description = "Name of the green target group"
  value       = aws_lb_target_group.ecs_tg_green.name
}

# --- Listener ARNs ---
output "https_listener_arn" {
  description = "ARN of the production HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "test_listener_arn" {
  description = "ARN of the test traffic listener for CodeDeploy"
  value       = aws_lb_listener.test.arn
}
