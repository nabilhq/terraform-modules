resource "aws_lambda_function" "main" {
  function_name = "${var.vpc_name}-${var.service_name}"
  description   = "forwards api requests from api gw to jenkins ec2 instance"
  s3_bucket     = aws_s3_bucket.main.id
  s3_key        = aws_s3_bucket_object.github_webhook_forwarder.key
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  role          = aws_iam_role.github_webhook_forwarder.arn

  vpc_config {
    subnet_ids         = [var.priv_subnet_a_id, var.priv_subnet_b_id]
    security_group_ids = [aws_security_group.main.id]
  }

  environment {
    variables = {
      jenkins_it_build_verification_token = var.jenkins_build_verification_token
      jenkins_it_api_secret_name          = aws_secretsmanager_secret.jenkins_api_credential.name
      aws_region                          = var.aws_region
    }
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_lambda_permission" "github_webhook_forwarder" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}