#-------------------------------------------------------aws_lb_------listener---------------------------------------

resource "aws_lb" "this" {
  #count              = length(var.availability_zone)
  name               = "basic-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  #subnets            = [element(aws_subnet.public.*.id,count.index)] 
   subnets           =  [for subnet in aws_subnet.public.* : subnet.id]
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "first" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



resource "aws_lb_listener" "second" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  aws_acm_certificate.aws_cmcloudlab674.arn

  #certificate_arn   = "${data.aws_acm_certificate.amazon_issued.arn}"
  depends_on        = [aws_lb_target_group.these, aws_acm_certificate.aws_cmcloudlab674]
  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.these.arn
  }
}

#------------------------------------------------------------aws_lb_target_group


resource "aws_lb_target_group" "these" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  load_balancing_algorithm_type = "least_outstanding_requests"

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  depends_on = [
    aws_lb.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

