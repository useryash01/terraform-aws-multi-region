output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ecs_instance_profile.name
}
