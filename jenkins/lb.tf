resource "aws_lb_target_group" "ec2" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.ec2.arn
  target_id        = aws_instance.ec2.id
  port             = 8080
}

resource "aws_lb" "ec2" {
  name               = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [var.priv_subnet_a_id, var.priv_subnet_b_id]

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_lb_listener" "ec2" {
  load_balancer_arn = aws_lb.ec2.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.domain_wildcard_cert_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2.arn
  }
}

resource "aws_lb_listener_certificate" "ec2" {
  listener_arn    = aws_lb_listener.ec2.arn
  certificate_arn = var.domain_wildcard_cert_id
}