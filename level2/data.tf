
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

data "aws_ami" "amazonlinux" {
  most_recent = true


  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230119.1-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}





