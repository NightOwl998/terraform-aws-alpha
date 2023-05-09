module "asg" {

  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.9.0"

  name                      = var.env_code
  vpc_zone_identifier       = data.terraform_remote_state.level1.outputs.private_subnet_id
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  force_delete              = true
  health_check_type         = "EC2"
  health_check_grace_period = 400
  target_group_arns         = module.lb.target_group_arns
  security_groups           = [module.private_sg.security_group_id]



  launch_template_name        = var.env_code
  launch_template_description = "Launch template description"
  update_default_version      = true
  launch_template_version     = "$Latest"
  image_id                    = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  user_data                   = filebase64("user-data.sh")

  create_iam_instance_profile = true
  iam_role_name               = var.env_code
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for session manager"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {

    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}
