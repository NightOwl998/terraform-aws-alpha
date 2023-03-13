module "vpc" {
  source            = "../modules/asg"
  env_code          = var.env_code
  vpc_id            = data.terraform_remote_state.level1.outputs.vpc_id
  private_subnet_id = data.terraform_remote_state.level1.outputs.private_subnet_id
  lb_tg_arn         = module.lb.lb_tg_arn
  lb_sg_id          = module.lb.lb_sg_id
}
