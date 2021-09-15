resource "aws_lambda_function" "github_webhook" {
  function_name = "${var.vpc_name}-${var.service_name}-github-webhook"
  description   = "forwards api requests from api gw to jenkins ec2 instance"
  s3_bucket     = aws_s3_bucket.main.id
  s3_key        = aws_s3_bucket_object.github_webhook.key
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  role          = aws_iam_role.main.arn

  source_code_hash = filebase64sha256("${var.github_webhook_lambda_package_path}")

  depends_on = [
    aws_cloudwatch_log_group.lambda_github_webhook
  ]

  vpc_config {
    subnet_ids         = [var.priv_subnet_a_id, var.priv_subnet_b_id]
    security_group_ids = [aws_security_group.main.id]
  }

  environment {
    variables = {
      jenkins_it_api_secret_name = aws_secretsmanager_secret.jenkins_prod_api_credential.name
      aws_region                 = var.aws_region
    }
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-github-webhook"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_lambda_permission" "github_webhook" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_function" "github_webhook_api_gw_authorizer" {
  function_name = "${var.vpc_name}-${var.service_name}-github-webhook-api-gw-authorizer"
  description   = "authorizer for the github webhook api end point"
  s3_bucket     = aws_s3_bucket.main.id
  s3_key        = aws_s3_bucket_object.github_webhook_authorizer.key
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  role          = aws_iam_role.lambda_github_webhook_authorizer.arn

  source_code_hash = filebase64sha256("${var.github_webhook_authorizer_lambda_package_path}")

  depends_on = [
    aws_cloudwatch_log_group.lambda_github_webhook_api_gw_authorizer
  ]

  environment {
    variables = {
      github_webhook_verification_token = var.github_webhook_verification_token
    }
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-github-webhook-api-gw-authorizer"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}