resource "aws_security_group" "ec2" {
  name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  description = "security group associated with the nat gateway ec2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.source_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.priv_subnet_a_cidr, var.priv_subnet_b_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.priv_subnet_a_cidr, var.priv_subnet_b_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.priv_subnet_a_cidr, var.priv_subnet_b_cidr]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}