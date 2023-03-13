resource "aws_security_group" "lb_sg" {
  name        = "load balancer sg"
  description = "Allow HTTP inbound traffic to ELB"
  vpc_id      = var.vpc_id
  ingress {
    description = "Http to ELB "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0 //65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env_code}lb_sg"
  }
}



resource "aws_lb" "mylb" {
  name                       = "${var.env_code}lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = var.public_subnet_id
  enable_deletion_protection = false

}
resource "aws_lb_target_group" "lb_tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5   // To consider an instance healthy it should make 5 healthy sucessive health checkups. 
    unhealthy_threshold = 2   // if the instance make 2 sucessive unhealthy checkups, it will be considered unreacheable. 
    timeout             = 5   // after 5s second no answer the elb will drop the instance
    interval            = 30  // an intervall of 30s between each checkup and another 
    matcher             = 200 // the response should be ok so we know it is healthy. 
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

data "aws_route53_zone" "main" {
  name = "fadiatestdevops.click"

}
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${data.aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.mylb.dns_name]
}