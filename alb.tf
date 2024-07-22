resource "aws_alb" "grafana-alb" {
  name            = "${var.name_prefix}-load-balancer"
  subnets         = aws_subnet.grafana-public.*.id
  security_groups = [aws_security_group.lb.id]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "${var.name_prefix}-lb"
    enabled = true
  }
}

#per instructions, running over port 80/http, but would forward
#to port 443 over https if production
resource "aws_alb_target_group" "app" {
  name        = "${var.name_prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.grafana.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.grafana-alb.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

# ALB security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "${var.name_prefix}-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.grafana.id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

