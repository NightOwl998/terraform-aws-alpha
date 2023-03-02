output "public_ip" {
  value = aws_instance.public[*].public_ip

}

output "loud_balancer_ip" {
  value = aws_lb.mylb.dns_name
}
