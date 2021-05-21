resource "aws_lambda_function" "github_webhook_forwarder" {
  function_name = "${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"
  description   = "forwards github webhooks from api gw to a jenkins ec2 instance"
  s3_bucket     = aws_s3_bucket.main.id
  s3_key        = aws_s3_bucket_object.github_webhook_forwarder.key
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  role          = aws_iam_role.github_webhook_forwarder.arn

  vpc_config {
    subnet_ids         = [var.priv_subnet_a_id, var.priv_subnet_b_id]
    security_group_ids = [aws_security_group.github_webhook_forwarder.id]
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_lambda_permission" "github_webhook_forwarder" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_webhook_forwarder.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}