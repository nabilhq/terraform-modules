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
  ami                         = data.aws_ami_ids.openvpn.ids[0]
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ec2.key_name
  subnet_id                   = var.priv_subnet_a_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

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

  user_data = <<USERDATA
admin_user=${var.openvpn_admin_username}
admin_pw=${var.openvpn_admin_password}
USERDATA

  provisioner "remote-exec" {
    connection {
      user        = "openvpnas"
      host        = self.public_ip
      private_key = file(var.ec2_private_key)
      timeout     = "10m"
    }

    inline = [
      "sleep 300",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.module.type\" --value \"radius\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.acct_enable\" --value \"true\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.server.0.host\" --value \"radius.us.onelogin.com\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.server.0.secret\" --value \"${var.openvpn_radius_shared_secret}\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.auth_method\" --value \"pap\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.name\" --value \"onelogin\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.server.0.acct_port\" --value \"1813\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"auth.radius.0.server.0.auth_port\" --value \"1812\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"vpn.server.daemon.enable\" --value \"false\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"vpn.daemon.0.listen.protocol\" --value \"tcp\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key \"vpn.server.port_share.enable\" --value \"true\" ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli start"
    ]
  }
}