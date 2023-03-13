output "load_balancer_url" {
  value = aws_lb.mylb.dns_name
}
output "lb_tg_arn" {
  value = aws_lb_target_group.lb_tg.arn
}
output "lb_sg_id" {
  value = aws_security_group.lb_sg.id
}



  
