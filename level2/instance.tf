resource "aws_instance" "public" {

  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[0]
  key_name                    = "main"
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true

  tags = {
    name = "${var.env_code}public_instance"
  }

}

resource "aws_security_group" "public" {
  name        = "${var.env_code}public"
  description = "Allow ssh inbound traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id
  ingress {
    description = "ssh from our lan"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIpAddress}/24"]


  }
  ingress {
    description = "Allow http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.myIpAddress}/24"]


  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_code}public_sg"
  }
}
resource "aws_security_group" "private" {
  name        = "${var.env_code}private"
  description = "Allow ssh inbound traffic from inside the vpc"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]

  }
  ingress {
    description     = "Allow http traffic"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]


  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_code}private_sg"
  }
}

