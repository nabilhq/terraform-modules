resource "aws_security_group" "ec2" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  description = "security group attached to the jenkins ec2 instances."
  vpc_id      = var.vpc_id

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_security_group_rule" "ec2_eg_wildcard" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_in_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_source]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_in_8080_lb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = aws_security_group.ec2.id
}

resource "aws_security_group" "lb" {
  name        = "lb-${var.vpc_name}-${var.service_name}-${var.environment}"
  description = "security group attached to the lb"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "lb-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_security_group_rule" "lb_in_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = -1
  cidr_blocks       = [var.web_source]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_eg_8080_ec2" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.lb.id
}