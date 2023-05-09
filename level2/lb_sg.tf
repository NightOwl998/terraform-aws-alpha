module "lb_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.2"
  name        = "load balancer sg"
  description = "Allow HTTPS inbound traffic to ELB"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id


  ingress_with_cidr_blocks = [
    {
      description = "Https to ELB "
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0 //65535
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"

    }
  ]
  tags = {
    Name = "${var.env_code}lb_sg"
  }
}
