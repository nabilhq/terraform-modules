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

variable environment {
  type        = string
  description = "environment the resources will be used in"
}

variable api_gw_stage_name {
  type        = string
  description = "api gateway deployment stage name"
}

variable priv_subnet_a_id {
  type = string
  description = "id of the primary private subnet"
}

variable priv_subnet_b_id {
  type = string
  description = "id of the secondary private subnet"
}

variable github_webhook_forwarder_lambda_package_path {
  type = string
  description = "path to the lambda package"
}