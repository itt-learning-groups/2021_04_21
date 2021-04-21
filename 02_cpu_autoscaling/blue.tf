resource "aws_launch_configuration" "blue" {
  name_prefix     = "webserver-blue-"
  image_id        = var.blue_ami
  instance_type   = "t2.micro"
  security_groups = [
    module.http_8080_security_group.this_security_group_id
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-webserver-alb"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     = 8080
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }

  tags = {
    Name    = "webserver-blue"
    Version = "blue"
  }
}

resource "aws_autoscaling_group" "blue" {
  name                      = "webserver-blue"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.blue.name
  target_group_arns         = [
    aws_lb_target_group.blue.arn
  ]
  vpc_zone_identifier       = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "webserver-blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "blue" {
  name                   = "scale-blue-by-cpu"
  autoscaling_group_name = aws_autoscaling_group.blue.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
