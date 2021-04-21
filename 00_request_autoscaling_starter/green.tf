resource "aws_launch_configuration" "green" {
  name_prefix     = ""   # !!!
  image_id        =    # !!!
  instance_type   = ""   # !!!
  security_groups = [module.webserver_security_group.this_security_group_id]

  lifecycle {
    create_before_destroy =    # !!!
  }
}

resource "aws_lb_target_group" "green" {
  name     = ""   # !!!
  port     =    # !!!
  protocol = ""   # !!!
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     =    # !!!
    protocol = ""   # !!!
    timeout  = 5
    interval = 10
  }

  tags = {
    Name    = ""   # !!!
    Version = "green"
  }
}

resource "aws_autoscaling_group" "green" {
  name                      = ""   # !!!
  min_size                  =    # !!!
  max_size                  =    # !!!
  desired_capacity          =    # !!!
  launch_configuration      =    # !!!
  target_group_arns         =    # !!!
  vpc_zone_identifier       = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "webserver-green"
    propagate_at_launch =    # !!!
  }
}
