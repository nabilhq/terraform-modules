variable "openvpn_admin_username" {
  type        = string
  description = "open vpn admin user"
}
variable "openvpn_admin_password" {
  type        = string
  description = "open vpn admin user password"
}

variable "source_ip" {
  type        = string
  description = "originating source public ip"
}

variable "openvpn_radius_shared_secret" {
  type        = string
  description = "RADIUS key to use."
}

variable "ec2_private_key" {
  type        = string
  description = "private key to use to ssh into the openvpn ec2 instance"
}

variable "ec2_public_key" {
  type        = string
  description = "public key to configure the ec2 instance with"
}

variable "main_domain_wildcard_cert" {
  type        = string
  description = "id of the main domain wildcard cert"
}

variable "main_domain_zone_id" {
  type        = string
  description = "id of the main domain zone id"
}

variable "domain" {
  type        = string
  description = "domain to use"
}

variable "vpc_id" {
  type        = string
  description = "id of the vpc to deploy to"
}

variable "vpc_name" {
  type        = string
  description = "name of the vpc"
}

data "aws_ami_ids" "openvpn" {
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["OpenVPN Access Server 2.7*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "priv_subnet_a_id" {
  type        = string
  description = "id of the primary private subnet"
}

variable "pub_subnet_a_id" {
  type        = string
  description = "id of the primary public subnet"
}

variable "pub_subnet_b_id" {
  type        = string
  description = "id of the secondary public subnet"
}

variable "service_name" {
  type        = string
  description = "service tag to assign to all of the tagable resources being created"
}

variable "environment" {
  type        = string
  description = "environment the resources will be used in"
}

variable "ec2_instance_type" {
  type        = string
  description = "ec2 instance type to use"
}

variable "ec2_root_volume_size" {
  type        = string
  description = "size of the ec2 instance root block device."
}

variable "ec2_root_volume_type" {
  type        = string
  description = "device type of the ec2 instance root block device."
}