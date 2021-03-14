resource "aws_key_pair" "ec2" {
  key_name   = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
  public_key = var.ec2_public_key

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami_ids.nat_gateway.ids[0]
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ec2.key_name
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  subnet_id                   = var.priv_subnet_a_id
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_type           = var.ec2_root_volume_type
    volume_size           = var.ec2_root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-${var.environment}"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}