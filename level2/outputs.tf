
output "loud_balancer_ip" {
  value = aws_lb.mylb.dns_name
}
