
data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "terraform-remote-state-d67cd9c15c2"
    key    = "level1.tfstate"
    region = "us-west-2"

  }
}

data "aws_secretsmanager_secret" "db_psswd" {
  name = "rds/password"
}
data "aws_secretsmanager_secret_version" "db_psswd" {
  secret_id = data.aws_secretsmanager_secret.db_psswd.id
  
}



