resource "aws_db_subnet_group" "this" {
  name       = "my_db_grp"
  subnet_ids = var.subnet_id


  tags = {
    Name = "${var.env_code}"
  }

}
resource "aws_security_group" "this" {
  name   = "rds"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups= [var.sec_grp]

  }



  tags = {
    Name = "${var.env_code}db_sg"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "my-db"
  allocated_storage       = 10
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  db_name                    = "mydb"
  username                = var.dbusername
  password                = var.dbpassword
  multi_az                = var.ha_db
  vpc_security_group_ids  = [aws_security_group.this.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  backup_retention_period = 20
  backup_window           = "02:00-03:30"
  skip_final_snapshot     = true


  tags = {
    Name = "${var.env_code}"
  }

}


