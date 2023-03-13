resource "aws_launch_configuration" "my-lt" {
  name_prefix          = "${var.env_code}-"
  image_id             = data.aws_ami.amazonlinux.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.private.id]
  user_data            = file("${path.module}/user-data.sh")
  key_name             = "main"
  iam_instance_profile = aws_iam_instance_profile.my-inst-profile.name



}

resource "aws_autoscaling_group" "my-asg" {
  name                 = var.env_code
  desired_capacity     = 1
  max_size             = 4
  min_size             = 1
  target_group_arns    = [var.lb_tg_arn]
  vpc_zone_identifier  = var.private_subnet_id
  launch_configuration = aws_launch_configuration.my-lt.name
  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true
  }
}
resource "aws_security_group" "private" {
  name        = "${var.env_code}private"
  description = "Allow http"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow http traffic"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lb_sg_id]


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


resource "aws_iam_role" "main" {
  name                = var.env_code
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "my-inst-profile" {
  name = var.env_code
  role = aws_iam_role.main.name
}

resource "aws_autoscaling_policy" "my_sp" {
  name                   = var.env_code
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.my-asg.name
}

resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = var.env_code
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my-asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.my_sp.arn]
}


