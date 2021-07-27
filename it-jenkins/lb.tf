resource "aws_lb_target_group" "lb_prod" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-prod"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_lb_target_group_attachment" "lb_prod" {
  target_group_arn = aws_lb_target_group.lb_prod.arn
  target_id        = aws_instance.ec2_prod.id
  port             = 8080
}

resource "aws_lb" "lb_prod" {
  name               = "ec2-${var.vpc_name}-${var.service_name}-prod"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [var.priv_subnet_a_id, var.priv_subnet_b_id]

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_lb_listener" "lb_prod" {
  load_balancer_arn = aws_lb.lb_prod.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.domain_wildcard_cert_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_prod.arn
  }
}

resource "aws_lb_listener_certificate" "lb_prod" {
  listener_arn    = aws_lb_listener.lb_prod.arn
  certificate_arn = var.domain_wildcard_cert_id
}

resource "aws_lb_target_group" "lb_staging" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-staging"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-staging"
    Service     = var.service_name
    Environment = "staging"
    Terraform   = true
  }
}

resource "aws_lb_target_group_attachment" "lb_staging" {
  target_group_arn = aws_lb_target_group.lb_staging.arn
  target_id        = aws_instance.ec2_staging.id
  port             = 8080
}

resource "aws_lb" "lb_staging" {
  name               = "ec2-${var.vpc_name}-${var.service_name}-staging"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [var.priv_subnet_a_id, var.priv_subnet_b_id]

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-staging"
    Service     = var.service_name
    Environment = "staging"
    Terraform   = true
  }
}

resource "aws_lb_listener" "lb_staging" {
  load_balancer_arn = aws_lb.lb_staging.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.domain_wildcard_cert_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_staging.arn
  }
}

resource "aws_lb_listener_certificate" "lb_staging" {
  listener_arn    = aws_lb_listener.lb_staging.arn
  certificate_arn = var.domain_wildcard_cert_id
}