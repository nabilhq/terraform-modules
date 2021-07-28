resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.vpc_name}-${var.service_name}"
  description = "forwards requests to jenkins via lambda."

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_api_gateway_resource" "github_webhook_forwarder" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "github_webhook_forwarder"
}

resource "aws_api_gateway_method" "github_webhook_forwarder" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.github_webhook_forwarder.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.jenkins_host" = true
  }
}

resource "aws_api_gateway_integration" "github_webhook_forwarder" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_method.github_webhook_forwarder.resource_id
  http_method             = aws_api_gateway_method.github_webhook_forwarder.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_resource" "build_trigger" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "build_trigger"
}

resource "aws_api_gateway_method" "build_trigger" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.build_trigger.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.verification_token" = true
    "method.request.querystring.jenkins_host"       = true
    "method.request.querystring.project_name"       = true
    "method.request.querystring.job_name"           = true
    "method.request.querystring.parameters"         = false
  }
}

resource "aws_api_gateway_integration" "build_trigger" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_method.build_trigger.resource_id
  http_method             = aws_api_gateway_method.build_trigger.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.api_gw_stage_name
  depends_on  = [aws_api_gateway_integration.github_webhook_forwarder, aws_api_gateway_integration.build_trigger]
}