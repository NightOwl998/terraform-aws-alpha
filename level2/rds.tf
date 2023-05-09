

resource "aws_security_group" "this" {
  name   = "rds"
  vpc_id = data.terraform_remote_state.level1.outputs.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.private_sg.security_group_id]

  }
}
resource "aws_db_subnet_group" "this" {
  name       = "my_db_grp"
  subnet_ids = data.terraform_remote_state.level1.outputs.private_subnet_id
}
module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "my-db"
  // db_subnet_group_name    = aws_db_subnet_group.this.name
  subnet_ids        = data.terraform_remote_state.level1.outputs.private_subnet_id
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 10

  db_name                             = "mydb"
  username                            = "admin"
  password                            = jsondecode(data.aws_secretsmanager_secret_version.db_psswd.secret_string)["password"]
  multi_az                            = true
  backup_retention_period             = 20
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = true
  vpc_security_group_ids              = [aws_security_group.this.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true



  # DB subnet group

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"






}

