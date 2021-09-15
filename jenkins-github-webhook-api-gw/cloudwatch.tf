resource "aws_cloudwatch_log_group" "api_gw_main" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/${var.api_gw_stage_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_github_webhook" {
  name              = "/aws/lambda/${var.vpc_name}-${var.service_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_github_webhook_api_gw_authorizer" {
  name              = "/aws/lambda/${var.vpc_name}-${var.service_name}-authorizer"
  retention_in_days = 30
}