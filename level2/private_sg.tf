module "private_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.2"
  name        = "${var.env_code}private"
  description = "Allow http"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [{
    rule                     = "http-80-tcp"
    source_security_group_id = module.lb_sg.security_group_id
  }]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"


    }
  ]
  tags = {
    Name = "${var.env_code}private_sg"
  }
}

