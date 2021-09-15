variable "aws_region" {
  type        = string
  description = "aws region to deploy the lambda to"
}

variable "lambda_vpc_access_arn" {
  type        = string
  description = "aws lambda vpc access iam policy arn."
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

variable "api_gw_stage_name" {
  type        = string
  description = "api gateway deployment stage name"
  default     = "prod"
}

variable "priv_subnet_a_id" {
  type        = string
  description = "id of the primary private subnet"
}

variable "priv_subnet_b_id" {
  type        = string
  description = "id of the secondary private subnet"
}

variable "github_webhook_authorizer_lambda_package_path" {
  type        = string
  description = "path to the lambda package for the github webhook authorizer"
}

variable "github_webhook_lambda_package_path" {
  type        = string
  description = "path to the lambda for the github webhook lambda"
}

variable "github_webhook_secret_arn" {
  type        = string
  description = "arn for the secret used by github to sign webhooks"
}

variable "github_webhook_secret_name" {
  type        = string
  description = "name for the secret used by github to sign webhooks"
}

variable "github_webhook_verification_token" {
  type = string
  description = "verification token to use as api token stored in query param from github"
}

variable "github_source_ips" {
  type        = string
  description = "source ip addresses to allow github webhooks from"
  default     = "[\"192.30.252.0/22\",\"185.199.108.0/22\",\"140.82.112.0/20\",\"143.55.64.0/20\"]"
}

variable "api_quota_limit" {
  type        = number
  description = "api gateway quota limit setting"
  default     = 50
}

variable "api_quota_period" {
  type        = string
  description = "api gateway quota period setting"
  default     = "WEEK"
}

variable "api_throttle_burst_limit" {
  type        = number
  description = "api gateway throttle setting burst limit"
  default     = 5
}

variable "api_throttle_rate_limit" {
  type        = number
  description = "api gateway throttle setting rate limit"
  default     = 10
}

variable "api_gw_tf_file_path" {
  type        = string
  description = "path to the api gw tf config file"
}