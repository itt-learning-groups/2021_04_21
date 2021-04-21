resource "aws_launch_configuration" "green" {
  name_prefix     = "webserver-green-"
  image_id        = var.green_ami
  instance_type   = "t2.micro"
  security_groups = [module.webserver_security_group.this_security_group_id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "green" {
  name     = "green-tg-webserver-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }

  tags = {
    Name    = "webserver-green"
    Version = "green"
  }
}

resource "aws_autoscaling_group" "green" {
  name                      = "webserver-green"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.green.name
  target_group_arns         = [aws_lb_target_group.green.arn]
  vpc_zone_identifier       = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "webserver-green"
    propagate_at_launch = true
  }
}
