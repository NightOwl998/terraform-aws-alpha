output "public_ip" {
  value = aws_instance.public[*].public_ip

}
output "private_ip" {
  value = aws_instance.private[*].private_ip

}
output "loud_balancer_ip" {
  value = aws_lb.mylb.dns_name
}
