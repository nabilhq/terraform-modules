resource "aws_api_gateway_rest_api" "main" {
  name           = "${var.vpc_name}-${var.service_name}"
  description    = "forwards requests to jenkins via lambda."
  api_key_source = "AUTHORIZER"


  tags = {
    Name        = "${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_api_gateway_rest_api_policy" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.main.execution_arn}/*/POST${aws_api_gateway_resource.github_webhook.path}",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": ${var.github_source_ips}
                }
            }
        }
    ]
}
POLICY
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.api_gw_stage_name
  depends_on  = [aws_api_gateway_integration.github_webhook]

  triggers = {
    api_gw_tf_file_hash = filebase64sha256("${var.api_gw_tf_file_path}")
  }
}

resource "aws_api_gateway_usage_plan" "main" {
  name        = "${var.vpc_name}-${var.service_name}"
  description = "usage plan attached to the ${var.service_name} methods"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = var.api_quota_limit
    period = var.api_quota_period
  }

  throttle_settings {
    burst_limit = var.api_throttle_burst_limit
    rate_limit  = var.api_throttle_rate_limit
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_deployment.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_rate_limit  = 10
    throttling_burst_limit = 5
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.api_gw_stage_name

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-${var.api_gw_stage_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_api_gateway_request_validator" "request_params" {
  name                        = "validate_request_params"
  rest_api_id                 = aws_api_gateway_rest_api.main.id
  validate_request_parameters = true
}

resource "aws_api_gateway_resource" "parent" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "jenkins"
}

resource "aws_api_gateway_authorizer" "github_webhook" {
  name                             = "${var.vpc_name}-${var.service_name}-github-webhook-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.main.id
  authorizer_uri                   = aws_lambda_function.github_webhook_api_gw_authorizer.invoke_arn
  authorizer_credentials           = aws_iam_role.api_gw_main.arn
  type                             = "REQUEST"
  authorizer_result_ttl_in_seconds = 0
  identity_source                  = ""
}

resource "aws_api_gateway_api_key" "github_webhook" {
  name        = var.service_name
  value       = var.github_webhook_verification_token
  description = "api key used by github webhook api endpoint to verify webhooks"
  enabled     = true
}

resource "aws_api_gateway_usage_plan_key" "github_webhook" {
  key_id        = aws_api_gateway_api_key.github_webhook.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

resource "aws_api_gateway_resource" "github_webhook" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.parent.id
  path_part   = "github_webhook"
}

resource "aws_api_gateway_method" "github_webhook" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.github_webhook.id
  http_method          = "POST"
  authorization        = "CUSTOM"
  authorizer_id        = aws_api_gateway_authorizer.github_webhook.id
  request_validator_id = aws_api_gateway_request_validator.request_params.id
  api_key_required     = true

  request_parameters = {
    "method.request.querystring.jenkins_host"       = true
    "method.request.header.X-Hub-Signature"         = true
    "method.request.querystring.verification_token" = true
  }
}

resource "aws_api_gateway_integration" "github_webhook" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_method.github_webhook.resource_id
  http_method             = aws_api_gateway_method.github_webhook.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.github_webhook.invoke_arn
}