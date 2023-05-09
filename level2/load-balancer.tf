module "lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"
  name    = "my-alb"

  load_balancer_type = "application"

  vpc_id = data.terraform_remote_state.level1.outputs.vpc_id

  subnets                    = data.terraform_remote_state.level1.outputs.public_subnet_id
  security_groups            = [module.lb_sg.security_group_id]
  enable_deletion_protection = false
  internal                   = false

  target_groups = [
    {
      name                 = "my-target-group"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      vpc_id               = data.terraform_remote_state.level1.outputs.vpc_id
      deregistration_delay = 10
      health_check = {
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
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]



}
