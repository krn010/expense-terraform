resource "aws_security_group" "main" {
  name        = "${local.name}-app-sg"
  description = "${local.name}-app-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_cidrs
    description      = "SSH"

  }

  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = var.sg_cidr_blocks
    description      = "App_Port"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}-app-sg"
  }
}


resource "aws_launch_template" "main" {
  name_prefix   = "${local.name}lt"
  image_id      = data.aws_ami.centos8.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_autoscaling_group" "main" {
  name                = "${local.name}-asg"
  desired_capacity    = var.instance_capactiy
  max_size            = var.instance_capactiy # TBD,  This we will fine tune after auto scaling
  min_size            = var.instance_capactiy
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
   tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${local.name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    timeout = 2
  }
}