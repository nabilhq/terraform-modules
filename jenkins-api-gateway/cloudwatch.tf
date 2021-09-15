resource "aws_cloudwatch_log_group" "lambda_github_webhook" {
  name              = "/aws/lambda/${var.service_name}-github-webhook"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_github_webhook_api_gw_authorizer" {
  name              = "${var.vpc_name}-${var.service_name}-github-webhook-api-gw-authorizer"
  retention_in_days = 30
}