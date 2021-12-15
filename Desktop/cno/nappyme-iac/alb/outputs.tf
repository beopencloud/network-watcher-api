output "lb_dns" {
  value         = aws_lb.nappyme_lb.dns_name
  description   = "The DNS name of the load balancer"
}

output "lb_zone_id" {
  value         = aws_lb.nappyme_lb.zone_id
  description   = "The canonical hosted zone ID of the load balancer "
}

output "lb_arn" {
  value         = aws_lb.nappyme_lb.arn
  description   = "The ARN of the ALB"
}

output "lb_arn_suffix" {
  value         = aws_lb.nappyme_lb.arn_suffix
  description   = "The ARN suffix of the ALB, useful with CloudWatch"
}

output "tg_arn" {
  value         = aws_lb_target_group.lb_target_group.arn
  description   = "The arn of the target group"
}

output "tg_arn_suffix" {
  value         = aws_lb_target_group.lb_target_group.arn_suffix
  description   = "The ARN suffix of the target group, useful with CloudWatch Metrics"
}

output "tg_name" {
   value        = aws_lb_target_group.lb_target_group.name
   description  = "The name of the target group"
}

output "listner_arn" {
   value        = aws_lb_listener.lb_listner.arn
   description  = "The ARN of the listener"
}

output "listner_id" {
   value        = aws_lb_listener.lb_listner.id
   description  = "The ID of the listeners"
}