variable "aws_region" {
  type        = string
  description = "aws region to deploy the lambda to"
}

variable lambda_vpc_access_arn {
  type        = string
  description = "aws lambda vpc access iam policy arn."
}

variable vpc_id {
  type        = string
  description = "id of the vpc to deploy in"
}

variable vpc_name {
  type        = string
  description = "name of the vpc"
}

variable service_name {
  type        = string
  description = "service tag to assign to all of the tagable resources being created"
}

variable api_gw_stage_name {
  type        = string
  description = "api gateway deployment stage name"
}

variable priv_subnet_a_id {
  type        = string
  description = "id of the primary private subnet"
}

variable priv_subnet_b_id {
  type        = string
  description = "id of the secondary private subnet"
}

variable lambda_package_path {
  type        = string
  description = "path to the lambda package"
}

variable jenkins_source_sg_id {
  type        = string
  description = "jenkins security group id"
}

variable "jenkins_api_token" {
  type        = string
  description = "jenkins api token"
}

variable "jenkins_api_username" {
  type        = string
  description = "jenkins api user"
}

variable "jenkins_build_verification_token" {
  type        = string
  description = "jenkins build trigger verification token"
}