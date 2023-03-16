module "rds" {
  source     = "../modules/rds"
  dbusername = "admin"
  dbpassword = jsondecode(data.aws_secretsmanager_secret_version.db_psswd.secret_string)["password"]
  ha_db      = true
  env_code   = var.env_code
  sec_grp    = module.asg.private_sg_id
  vpc_id     = data.terraform_remote_state.level1.outputs.vpc_id
  subnet_id  = data.terraform_remote_state.level1.outputs.private_subnet_id

}

