resource "aws_security_group" "ec2" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  vpc_id      = var.vpc_id
  description = "openvpn ec2 instance security group"

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_security_group_rule" "ec2_in_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.source_ip]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_in_443_lb" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_in_443_vpn" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.source_ip]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_eg_wildcard" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group" "lb" {
  name        = "lb-${var.vpc_name}-${var.service_name}-${var.environment}"
  vpc_id      = var.vpc_id
  description = "${var.service_name}-${var.environment} lb security group"

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
  protocol          = "tcp"
  cidr_blocks       = [var.source_ip]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_eg_443" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.lb.id
} 