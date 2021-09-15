resource "aws_lb_target_group" "ec2_prod" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-prod"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path = "/login"
  }

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_lb_target_group_attachment" "ec2_prod" {
  target_group_arn = aws_lb_target_group.ec2_prod.arn
  target_id        = aws_instance.ec2_prod.id
  port             = 8080
}

resource "aws_lb" "ec2_prod" {
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

resource "aws_lb_listener" "ec2_prod" {
  load_balancer_arn = aws_lb.ec2_prod.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.domain_wildcard_cert_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_prod.arn
  }
}

resource "aws_lb_listener_certificate" "ec2_prod" {
  listener_arn    = aws_lb_listener.ec2_prod.arn
  certificate_arn = var.domain_wildcard_cert_id
}

resource "aws_lb_target_group" "ec2_staging" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-staging"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path = "/login"
  }

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-staging"
    Service     = var.service_name
    Environment = "staging"
    Terraform   = true
  }
}

resource "aws_lb_target_group_attachment" "ec2_staging" {
  target_group_arn = aws_lb_target_group.ec2_staging.arn
  target_id        = aws_instance.ec2_staging.id
  port             = 8080
}

resource "aws_lb" "ec2_staging" {
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

resource "aws_lb_listener" "ec2_staging" {
  load_balancer_arn = aws_lb.ec2_staging.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.domain_wildcard_cert_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_staging.arn
  }
}

resource "aws_lb_listener_certificate" "ec2_staging" {
  listener_arn    = aws_lb_listener.ec2_staging.arn
  certificate_arn = var.domain_wildcard_cert_id
}