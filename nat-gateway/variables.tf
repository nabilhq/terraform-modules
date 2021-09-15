variable "ec2_public_key" {
  type        = string
  description = "public key to use when configuring the ec2 instance."
}

variable "source_ip" {
  type        = string
  description = "originating source public ip"
}

data "aws_ami_ids" "nat_gateway" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "vpc_id" {
  type        = string
  description = "id of the vpc to deploy in"
}

variable "vpc_name" {
  type        = string
  description = "name of the vpc"
}

variable "service_name" {
  type        = string
  description = "service tag to assign to all of the tagable resources being created"
}

variable "environment" {
  type        = string
  description = "environment the resources will be used in"
}

variable "priv_subnet_a_id" {
  type        = string
  description = "id of primary private subnet."
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

variable "priv_subnet_a_cidr" {
  type        = string
  description = "cidr lock of the primary private subnet."
}

variable "priv_subnet_b_cidr" {
  type        = string
  description = "cidr block of the secondary private subnet."
}

variable "priv_subnet_route_table_id" {
  type        = string
  description = "id of the route table attached to the private subnets."
}